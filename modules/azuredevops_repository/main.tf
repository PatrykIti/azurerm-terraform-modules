# Azure DevOps Repository

locals {
  repository_enabled = var.name != null

  initialization       = var.initialization == null ? {} : var.initialization
  repository_init_type = coalesce(try(local.initialization.init_type, null), "Uninitialized")
  repository_initialization = {
    init_type             = local.repository_init_type
    source_type           = local.repository_init_type == "Import" ? coalesce(try(local.initialization.source_type, null), "Git") : null
    source_url            = local.repository_init_type == "Import" ? try(local.initialization.source_url, null) : null
    service_connection_id = local.repository_init_type == "Import" ? try(local.initialization.service_connection_id, null) : null
    username              = local.repository_init_type == "Import" ? try(local.initialization.username, null) : null
    password              = local.repository_init_type == "Import" ? try(local.initialization.password, null) : null
  }

  repository_id      = try(azuredevops_git_repository.git_repository[0].id, null)
  default_ref_branch = coalesce(var.default_branch, "refs/heads/master")

  branches_by_key = {
    for branch in var.branches : coalesce(branch.key, branch.name) => merge(branch, {
      repository_id = coalesce(branch.repository_id, local.repository_id)
      ref_branch = (
        branch.ref_tag == null && branch.ref_commit_id == null
        ? coalesce(branch.ref_branch, local.default_ref_branch)
        : branch.ref_branch
      )
    })
  }

  files_by_key = {
    for file in var.files : coalesce(file.key, file.file) => merge(file, {
      repository_id = coalesce(file.repository_id, local.repository_id)
    })
  }

  git_permissions_by_key = {
    for permission in var.git_permissions : coalesce(
      permission.key,
      format(
        "%s:%s",
        coalesce(permission.branch_name, "root"),
        permission.principal
      )
      ) => merge(permission, {
        repository_id = coalesce(permission.repository_id, local.repository_id)
    })
  }

  branch_policy_auto_reviewers_by_key = {
    for policy in var.branch_policy_auto_reviewers : coalesce(policy.key, "auto_reviewers") => merge(policy, {
      scope = [
        for scope in policy.scope : merge(scope, {
          match_type     = coalesce(scope.match_type, "DefaultBranch")
          repository_id  = coalesce(scope.repository_id, local.repository_id)
          repository_ref = coalesce(scope.match_type, "DefaultBranch") == "DefaultBranch" ? null : scope.repository_ref
        })
      ]
    })
  }

  branch_policy_build_validation_by_key = {
    for policy in var.branch_policy_build_validation : coalesce(policy.key, "build_validation") => merge(policy, {
      scope = [
        for scope in policy.scope : merge(scope, {
          match_type     = coalesce(scope.match_type, "DefaultBranch")
          repository_id  = coalesce(scope.repository_id, local.repository_id)
          repository_ref = coalesce(scope.match_type, "DefaultBranch") == "DefaultBranch" ? null : scope.repository_ref
        })
      ]
    })
  }

  branch_policy_comment_resolution_by_key = {
    for policy in var.branch_policy_comment_resolution : coalesce(policy.key, "comment_resolution") => merge(policy, {
      scope = [
        for scope in policy.scope : merge(scope, {
          match_type     = coalesce(scope.match_type, "DefaultBranch")
          repository_id  = coalesce(scope.repository_id, local.repository_id)
          repository_ref = coalesce(scope.match_type, "DefaultBranch") == "DefaultBranch" ? null : scope.repository_ref
        })
      ]
    })
  }

  branch_policy_merge_types_by_key = {
    for policy in var.branch_policy_merge_types : coalesce(policy.key, "merge_types") => merge(policy, {
      scope = [
        for scope in policy.scope : merge(scope, {
          match_type     = coalesce(scope.match_type, "DefaultBranch")
          repository_id  = coalesce(scope.repository_id, local.repository_id)
          repository_ref = coalesce(scope.match_type, "DefaultBranch") == "DefaultBranch" ? null : scope.repository_ref
        })
      ]
    })
  }

  branch_policy_min_reviewers_by_key = {
    for policy in var.branch_policy_min_reviewers : coalesce(policy.key, "min_reviewers") => merge(policy, {
      scope = [
        for scope in policy.scope : merge(scope, {
          match_type     = coalesce(scope.match_type, "DefaultBranch")
          repository_id  = coalesce(scope.repository_id, local.repository_id)
          repository_ref = coalesce(scope.match_type, "DefaultBranch") == "DefaultBranch" ? null : scope.repository_ref
        })
      ]
    })
  }

  branch_policy_status_check_by_key = {
    for policy in var.branch_policy_status_check : coalesce(policy.key, "status_check") => merge(policy, {
      scope = [
        for scope in policy.scope : merge(scope, {
          match_type     = coalesce(scope.match_type, "DefaultBranch")
          repository_id  = coalesce(scope.repository_id, local.repository_id)
          repository_ref = coalesce(scope.match_type, "DefaultBranch") == "DefaultBranch" ? null : scope.repository_ref
        })
      ]
    })
  }

  branch_policy_work_item_linking_by_key = {
    for policy in var.branch_policy_work_item_linking : coalesce(policy.key, "work_item_linking") => merge(policy, {
      scope = [
        for scope in policy.scope : merge(scope, {
          match_type     = coalesce(scope.match_type, "DefaultBranch")
          repository_id  = coalesce(scope.repository_id, local.repository_id)
          repository_ref = coalesce(scope.match_type, "DefaultBranch") == "DefaultBranch" ? null : scope.repository_ref
        })
      ]
    })
  }

  repository_policy_author_email_pattern_by_key = {
    for policy in var.repository_policy_author_email_pattern : coalesce(policy.key, "author_email_pattern") => merge(policy, {
      repository_ids = distinct([
        for repository_id in compact(coalesce(policy.repository_ids, [local.repository_id])) : trimspace(repository_id)
      ])
    })
  }

  repository_policy_case_enforcement_by_key = {
    for policy in var.repository_policy_case_enforcement : coalesce(policy.key, "case_enforcement") => merge(policy, {
      repository_ids = distinct([
        for repository_id in compact(coalesce(policy.repository_ids, [local.repository_id])) : trimspace(repository_id)
      ])
    })
  }

  repository_policy_file_path_pattern_by_key = {
    for policy in var.repository_policy_file_path_pattern : coalesce(policy.key, "file_path_pattern") => merge(policy, {
      repository_ids = distinct([
        for repository_id in compact(coalesce(policy.repository_ids, [local.repository_id])) : trimspace(repository_id)
      ])
    })
  }

  repository_policy_max_file_size_by_key = {
    for policy in var.repository_policy_max_file_size : coalesce(policy.key, "max_file_size") => merge(policy, {
      repository_ids = distinct([
        for repository_id in compact(coalesce(policy.repository_ids, [local.repository_id])) : trimspace(repository_id)
      ])
    })
  }

  repository_policy_max_path_length_by_key = {
    for policy in var.repository_policy_max_path_length : coalesce(policy.key, "max_path_length") => merge(policy, {
      repository_ids = distinct([
        for repository_id in compact(coalesce(policy.repository_ids, [local.repository_id])) : trimspace(repository_id)
      ])
    })
  }

  repository_policy_reserved_names_by_key = {
    for policy in var.repository_policy_reserved_names : coalesce(policy.key, "reserved_names") => merge(policy, {
      repository_ids = distinct([
        for repository_id in compact(coalesce(policy.repository_ids, [local.repository_id])) : trimspace(repository_id)
      ])
    })
  }
}

resource "azuredevops_git_repository" "git_repository" {
  count = local.repository_enabled ? 1 : 0

  project_id           = var.project_id
  name                 = var.name
  default_branch       = var.default_branch
  parent_repository_id = var.parent_repository_id
  disabled             = var.disabled

  initialization {
    init_type             = local.repository_initialization.init_type
    source_type           = local.repository_initialization.source_type
    source_url            = local.repository_initialization.source_url
    service_connection_id = local.repository_initialization.service_connection_id
    username              = local.repository_initialization.username
    password              = local.repository_initialization.password
  }
}

resource "azuredevops_git_repository_branch" "git_repository_branch" {
  for_each = local.branches_by_key

  repository_id = each.value.repository_id
  name          = each.value.name
  ref_branch    = each.value.ref_branch
  ref_tag       = each.value.ref_tag
  ref_commit_id = each.value.ref_commit_id

  lifecycle {
    precondition {
      condition     = each.value.repository_id != null
      error_message = "branches.repository_id is required when the module repository is not created."
    }
  }
}

resource "azuredevops_git_repository_file" "git_repository_file" {
  for_each = local.files_by_key

  repository_id       = each.value.repository_id
  file                = each.value.file
  content             = each.value.content
  branch              = each.value.branch
  commit_message      = each.value.commit_message
  overwrite_on_create = each.value.overwrite_on_create
  author_name         = each.value.author_name
  author_email        = each.value.author_email
  committer_name      = each.value.committer_name
  committer_email     = each.value.committer_email

  lifecycle {
    precondition {
      condition     = each.value.repository_id != null
      error_message = "files.repository_id is required when the module repository is not created."
    }
  }
}

resource "azuredevops_git_permissions" "git_permissions" {
  for_each = local.git_permissions_by_key

  project_id    = var.project_id
  repository_id = each.value.repository_id
  branch_name   = each.value.branch_name
  principal     = each.value.principal
  permissions   = each.value.permissions
  replace       = each.value.replace

  lifecycle {
    precondition {
      condition     = each.value.repository_id != null
      error_message = "git_permissions.repository_id is required when the module repository is not created."
    }
  }
}

resource "azuredevops_branch_policy_auto_reviewers" "branch_policy_auto_reviewers" {
  for_each = local.branch_policy_auto_reviewers_by_key

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    auto_reviewer_ids           = each.value.auto_reviewer_ids
    path_filters                = each.value.path_filters
    submitter_can_vote          = each.value.submitter_can_vote
    message                     = each.value.message
    minimum_number_of_reviewers = each.value.minimum_number_of_reviewers

    dynamic "scope" {
      for_each = each.value.scope
      content {
        repository_id  = scope.value.repository_id
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for scope in each.value.scope : scope.match_type == "DefaultBranch" ? true : scope.repository_id != null])
      error_message = "branch_policy_auto_reviewers.scope.repository_id is required when the module repository is not created."
    }
  }
}

resource "azuredevops_branch_policy_build_validation" "branch_policy_build_validation" {
  for_each = local.branch_policy_build_validation_by_key

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    build_definition_id         = each.value.build_definition_id
    display_name                = each.value.display_name
    manual_queue_only           = each.value.manual_queue_only
    queue_on_source_update_only = each.value.queue_on_source_update_only
    valid_duration              = each.value.valid_duration
    filename_patterns           = each.value.filename_patterns

    dynamic "scope" {
      for_each = each.value.scope
      content {
        repository_id  = scope.value.repository_id
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for scope in each.value.scope : scope.match_type == "DefaultBranch" ? true : scope.repository_id != null])
      error_message = "branch_policy_build_validation.scope.repository_id is required when the module repository is not created."
    }
  }
}

resource "azuredevops_branch_policy_comment_resolution" "branch_policy_comment_resolution" {
  for_each = local.branch_policy_comment_resolution_by_key

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    dynamic "scope" {
      for_each = each.value.scope
      content {
        repository_id  = scope.value.repository_id
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for scope in each.value.scope : scope.match_type == "DefaultBranch" ? true : scope.repository_id != null])
      error_message = "branch_policy_comment_resolution.scope.repository_id is required when the module repository is not created."
    }
  }
}

resource "azuredevops_branch_policy_merge_types" "branch_policy_merge_types" {
  for_each = local.branch_policy_merge_types_by_key

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    allow_squash                  = each.value.allow_squash
    allow_rebase_and_fast_forward = each.value.allow_rebase_and_fast_forward
    allow_basic_no_fast_forward   = each.value.allow_basic_no_fast_forward
    allow_rebase_with_merge       = each.value.allow_rebase_with_merge

    dynamic "scope" {
      for_each = each.value.scope
      content {
        repository_id  = scope.value.repository_id
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for scope in each.value.scope : scope.match_type == "DefaultBranch" ? true : scope.repository_id != null])
      error_message = "branch_policy_merge_types.scope.repository_id is required when the module repository is not created."
    }
  }
}

resource "azuredevops_branch_policy_min_reviewers" "branch_policy_min_reviewers" {
  for_each = local.branch_policy_min_reviewers_by_key

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

    dynamic "scope" {
      for_each = each.value.scope
      content {
        repository_id  = scope.value.repository_id
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for scope in each.value.scope : scope.match_type == "DefaultBranch" ? true : scope.repository_id != null])
      error_message = "branch_policy_min_reviewers.scope.repository_id is required when the module repository is not created."
    }
  }
}

resource "azuredevops_branch_policy_status_check" "branch_policy_status_check" {
  for_each = local.branch_policy_status_check_by_key

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    name                 = each.value.name
    genre                = each.value.genre
    author_id            = each.value.author_id
    invalidate_on_update = each.value.invalidate_on_update
    applicability        = each.value.applicability
    filename_patterns    = each.value.filename_patterns
    display_name         = each.value.display_name

    dynamic "scope" {
      for_each = each.value.scope
      content {
        repository_id  = scope.value.repository_id
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for scope in each.value.scope : scope.match_type == "DefaultBranch" ? true : scope.repository_id != null])
      error_message = "branch_policy_status_check.scope.repository_id is required when the module repository is not created."
    }
  }
}

resource "azuredevops_branch_policy_work_item_linking" "branch_policy_work_item_linking" {
  for_each = local.branch_policy_work_item_linking_by_key

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    dynamic "scope" {
      for_each = each.value.scope
      content {
        repository_id  = scope.value.repository_id
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for scope in each.value.scope : scope.match_type == "DefaultBranch" ? true : scope.repository_id != null])
      error_message = "branch_policy_work_item_linking.scope.repository_id is required when the module repository is not created."
    }
  }
}

resource "azuredevops_repository_policy_author_email_pattern" "repository_policy_author_email_pattern" {
  for_each = local.repository_policy_author_email_pattern_by_key

  project_id            = var.project_id
  enabled               = each.value.enabled
  blocking              = each.value.blocking
  author_email_patterns = each.value.author_email_patterns
  repository_ids        = each.value.repository_ids

  lifecycle {
    precondition {
      condition     = length(each.value.repository_ids) > 0
      error_message = "repository_policy_author_email_pattern.repository_ids must not be empty."
    }
  }
}

resource "azuredevops_repository_policy_case_enforcement" "repository_policy_case_enforcement" {
  for_each = local.repository_policy_case_enforcement_by_key

  project_id              = var.project_id
  enabled                 = each.value.enabled
  blocking                = each.value.blocking
  enforce_consistent_case = each.value.enforce_consistent_case
  repository_ids          = each.value.repository_ids

  lifecycle {
    precondition {
      condition     = length(each.value.repository_ids) > 0
      error_message = "repository_policy_case_enforcement.repository_ids must not be empty."
    }
  }
}

resource "azuredevops_repository_policy_file_path_pattern" "repository_policy_file_path_pattern" {
  for_each = local.repository_policy_file_path_pattern_by_key

  project_id        = var.project_id
  enabled           = each.value.enabled
  blocking          = each.value.blocking
  filepath_patterns = each.value.filepath_patterns
  repository_ids    = each.value.repository_ids

  lifecycle {
    precondition {
      condition     = length(each.value.repository_ids) > 0
      error_message = "repository_policy_file_path_pattern.repository_ids must not be empty."
    }
  }
}

resource "azuredevops_repository_policy_max_file_size" "repository_policy_max_file_size" {
  for_each = local.repository_policy_max_file_size_by_key

  project_id     = var.project_id
  enabled        = each.value.enabled
  blocking       = each.value.blocking
  max_file_size  = each.value.max_file_size
  repository_ids = each.value.repository_ids

  lifecycle {
    precondition {
      condition     = length(each.value.repository_ids) > 0
      error_message = "repository_policy_max_file_size.repository_ids must not be empty."
    }
  }
}

resource "azuredevops_repository_policy_max_path_length" "repository_policy_max_path_length" {
  for_each = local.repository_policy_max_path_length_by_key

  project_id      = var.project_id
  enabled         = each.value.enabled
  blocking        = each.value.blocking
  max_path_length = each.value.max_path_length
  repository_ids  = each.value.repository_ids

  lifecycle {
    precondition {
      condition     = length(each.value.repository_ids) > 0
      error_message = "repository_policy_max_path_length.repository_ids must not be empty."
    }
  }
}

resource "azuredevops_repository_policy_reserved_names" "repository_policy_reserved_names" {
  for_each = local.repository_policy_reserved_names_by_key

  project_id     = var.project_id
  enabled        = each.value.enabled
  blocking       = each.value.blocking
  repository_ids = each.value.repository_ids

  lifecycle {
    precondition {
      condition     = length(each.value.repository_ids) > 0
      error_message = "repository_policy_reserved_names.repository_ids must not be empty."
    }
  }
}
