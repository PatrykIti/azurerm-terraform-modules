# Azure DevOps Repository

locals {
  default_ref_branch = coalesce(var.default_branch, "refs/heads/master")

  branches_by_name = {
    for branch in var.branches : branch.name => merge(branch, {
      ref_branch = (
        branch.ref_tag == null && branch.ref_commit_id == null
        ? coalesce(branch.ref_branch, local.default_ref_branch)
        : branch.ref_branch
      )
    })
  }

  files_by_key = {
    for file in var.files : format("%s:%s", file.file, coalesce(file.branch, "default")) => file
  }

  git_permissions_by_key = {
    for permission in var.git_permissions : format(
      "%s:%s",
      coalesce(permission.branch_name, "root"),
      permission.principal
    ) => permission
  }

  branch_policy_min_reviewers_by_branch = {
    for branch in var.branches : branch.name => branch.policies.min_reviewers
    if branch.policies.min_reviewers != null
  }

  branch_policy_comment_resolution_by_branch = {
    for branch in var.branches : branch.name => branch.policies.comment_resolution
    if branch.policies.comment_resolution != null
  }

  branch_policy_work_item_linking_by_branch = {
    for branch in var.branches : branch.name => branch.policies.work_item_linking
    if branch.policies.work_item_linking != null
  }

  branch_policy_merge_types_by_branch = {
    for branch in var.branches : branch.name => branch.policies.merge_types
    if branch.policies.merge_types != null
  }

  branch_policy_build_validation_by_name = {
    for item in flatten([
      for branch in var.branches : [
        for policy in coalesce(try(branch.policies.build_validation, []), []) : {
          branch = branch
          policy = policy
        }
      ]
    ]) : item.policy.name => item
  }

  branch_policy_status_check_by_name = {
    for item in flatten([
      for branch in var.branches : [
        for policy in coalesce(try(branch.policies.status_check, []), []) : {
          branch = branch
          policy = policy
        }
      ]
    ]) : item.policy.name => item
  }

  branch_policy_auto_reviewers_by_name = {
    for item in flatten([
      for branch in var.branches : [
        for policy in coalesce(try(branch.policies.auto_reviewers, []), []) : {
          branch = branch
          policy = policy
        }
      ]
    ]) : item.policy.name => item
  }

}

resource "azuredevops_git_repository" "git_repository" {
  project_id           = var.project_id
  name                 = var.name
  default_branch       = var.default_branch
  parent_repository_id = var.parent_repository_id
  disabled             = var.disabled

  dynamic "initialization" {
    for_each = var.initialization == null ? [] : [{
      init_type             = coalesce(var.initialization.init_type, "Uninitialized")
      source_type           = coalesce(var.initialization.init_type, "Uninitialized") == "Import" ? coalesce(var.initialization.source_type, "Git") : null
      source_url            = coalesce(var.initialization.init_type, "Uninitialized") == "Import" ? var.initialization.source_url : null
      service_connection_id = coalesce(var.initialization.init_type, "Uninitialized") == "Import" ? var.initialization.service_connection_id : null
      username              = coalesce(var.initialization.init_type, "Uninitialized") == "Import" ? var.initialization.username : null
      password              = coalesce(var.initialization.init_type, "Uninitialized") == "Import" ? var.initialization.password : null
    }]
    content {
      init_type             = initialization.value.init_type
      source_type           = initialization.value.source_type
      source_url            = initialization.value.source_url
      service_connection_id = initialization.value.service_connection_id
      username              = initialization.value.username
      password              = initialization.value.password
    }
  }
}

resource "azuredevops_git_repository_branch" "git_repository_branch" {
  for_each = local.branches_by_name

  repository_id = azuredevops_git_repository.git_repository.id
  name          = each.value.name
  ref_branch    = each.value.ref_branch
  ref_tag       = each.value.ref_tag
  ref_commit_id = each.value.ref_commit_id
}

resource "azuredevops_git_repository_file" "git_repository_file" {
  for_each = local.files_by_key

  repository_id       = azuredevops_git_repository.git_repository.id
  file                = each.value.file
  content             = each.value.content
  branch              = each.value.branch
  commit_message      = each.value.commit_message
  overwrite_on_create = each.value.overwrite_on_create
  author_name         = each.value.author_name
  author_email        = each.value.author_email
  committer_name      = each.value.committer_name
  committer_email     = each.value.committer_email
}

resource "azuredevops_git_permissions" "git_permissions" {
  for_each = local.git_permissions_by_key

  project_id    = var.project_id
  repository_id = azuredevops_git_repository.git_repository.id
  branch_name   = each.value.branch_name
  principal     = each.value.principal
  permissions   = each.value.permissions
  replace       = each.value.replace
}

resource "azuredevops_branch_policy_auto_reviewers" "branch_policy_auto_reviewers" {
  for_each = local.branch_policy_auto_reviewers_by_name

  project_id = var.project_id
  enabled    = each.value.policy.enabled
  blocking   = each.value.policy.blocking

  settings {
    auto_reviewer_ids           = each.value.policy.auto_reviewer_ids
    path_filters                = each.value.policy.path_filters
    submitter_can_vote          = each.value.policy.submitter_can_vote
    message                     = each.value.policy.message
    minimum_number_of_reviewers = each.value.policy.minimum_number_of_reviewers

    scope {
      repository_id  = azuredevops_git_repository.git_repository.id
      repository_ref = format("refs/heads/%s", each.value.branch.name)
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_build_validation" "branch_policy_build_validation" {
  for_each = local.branch_policy_build_validation_by_name

  project_id = var.project_id
  enabled    = each.value.policy.enabled
  blocking   = each.value.policy.blocking

  settings {
    build_definition_id         = each.value.policy.build_definition_id
    display_name                = each.value.policy.display_name
    manual_queue_only           = each.value.policy.manual_queue_only
    queue_on_source_update_only = each.value.policy.queue_on_source_update_only
    valid_duration              = each.value.policy.valid_duration
    filename_patterns           = each.value.policy.filename_patterns

    scope {
      repository_id  = azuredevops_git_repository.git_repository.id
      repository_ref = format("refs/heads/%s", each.value.branch.name)
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_comment_resolution" "branch_policy_comment_resolution" {
  for_each = local.branch_policy_comment_resolution_by_branch

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    scope {
      repository_id  = azuredevops_git_repository.git_repository.id
      repository_ref = format("refs/heads/%s", each.key)
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_merge_types" "branch_policy_merge_types" {
  for_each = local.branch_policy_merge_types_by_branch

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    allow_squash                  = each.value.allow_squash
    allow_rebase_and_fast_forward = each.value.allow_rebase_and_fast_forward
    allow_basic_no_fast_forward   = each.value.allow_basic_no_fast_forward
    allow_rebase_with_merge       = each.value.allow_rebase_with_merge

    scope {
      repository_id  = azuredevops_git_repository.git_repository.id
      repository_ref = format("refs/heads/%s", each.key)
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_min_reviewers" "branch_policy_min_reviewers" {
  for_each = local.branch_policy_min_reviewers_by_branch

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    reviewer_count                         = each.value.reviewer_count
    submitter_can_vote                     = each.value.submitter_can_vote
    last_pusher_cannot_approve             = each.value.last_pusher_cannot_approve
    allow_completion_with_rejects_or_waits = each.value.allow_completion_with_rejects_or_waits
    on_push_reset_approved_votes           = each.value.on_push_reset_approved_votes
    on_push_reset_all_votes                = each.value.on_push_reset_all_votes
    on_last_iteration_require_vote         = each.value.on_last_iteration_require_vote

    scope {
      repository_id  = azuredevops_git_repository.git_repository.id
      repository_ref = format("refs/heads/%s", each.key)
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_status_check" "branch_policy_status_check" {
  for_each = local.branch_policy_status_check_by_name

  project_id = var.project_id
  enabled    = each.value.policy.enabled
  blocking   = each.value.policy.blocking

  settings {
    name                 = each.value.policy.name
    genre                = each.value.policy.genre
    author_id            = each.value.policy.author_id
    invalidate_on_update = each.value.policy.invalidate_on_update
    applicability        = each.value.policy.applicability
    filename_patterns    = each.value.policy.filename_patterns
    display_name         = each.value.policy.display_name

    scope {
      repository_id  = azuredevops_git_repository.git_repository.id
      repository_ref = format("refs/heads/%s", each.value.branch.name)
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_branch_policy_work_item_linking" "branch_policy_work_item_linking" {
  for_each = local.branch_policy_work_item_linking_by_branch

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    scope {
      repository_id  = azuredevops_git_repository.git_repository.id
      repository_ref = format("refs/heads/%s", each.key)
      match_type     = "Exact"
    }
  }
}

resource "azuredevops_repository_policy_author_email_pattern" "repository_policy_author_email_pattern" {
  count = var.policies.author_email_pattern == null ? 0 : 1

  project_id            = var.project_id
  enabled               = var.policies.author_email_pattern.enabled
  blocking              = var.policies.author_email_pattern.blocking
  author_email_patterns = var.policies.author_email_pattern.author_email_patterns
  repository_ids        = [azuredevops_git_repository.git_repository.id]
}

resource "azuredevops_repository_policy_case_enforcement" "repository_policy_case_enforcement" {
  count = var.policies.case_enforcement == null ? 0 : 1

  project_id              = var.project_id
  enabled                 = var.policies.case_enforcement.enabled
  blocking                = var.policies.case_enforcement.blocking
  enforce_consistent_case = var.policies.case_enforcement.enforce_consistent_case
  repository_ids          = [azuredevops_git_repository.git_repository.id]
}

resource "azuredevops_repository_policy_file_path_pattern" "repository_policy_file_path_pattern" {
  count = var.policies.file_path_pattern == null ? 0 : 1

  project_id        = var.project_id
  enabled           = var.policies.file_path_pattern.enabled
  blocking          = var.policies.file_path_pattern.blocking
  filepath_patterns = var.policies.file_path_pattern.filepath_patterns
  repository_ids    = [azuredevops_git_repository.git_repository.id]
}

resource "azuredevops_repository_policy_max_file_size" "repository_policy_max_file_size" {
  count = var.policies.maximum_file_size == null ? 0 : 1

  project_id     = var.project_id
  enabled        = var.policies.maximum_file_size.enabled
  blocking       = var.policies.maximum_file_size.blocking
  max_file_size  = var.policies.maximum_file_size.max_file_size
  repository_ids = [azuredevops_git_repository.git_repository.id]
}

resource "azuredevops_repository_policy_max_path_length" "repository_policy_max_path_length" {
  count = var.policies.maximum_path_length == null ? 0 : 1

  project_id      = var.project_id
  enabled         = var.policies.maximum_path_length.enabled
  blocking        = var.policies.maximum_path_length.blocking
  max_path_length = var.policies.maximum_path_length.max_path_length
  repository_ids  = [azuredevops_git_repository.git_repository.id]
}

resource "azuredevops_repository_policy_reserved_names" "repository_policy_reserved_names" {
  count = var.policies.reserved_names == null ? 0 : 1

  project_id     = var.project_id
  enabled        = var.policies.reserved_names.enabled
  blocking       = var.policies.reserved_names.blocking
  repository_ids = [azuredevops_git_repository.git_repository.id]
}
