# Azure DevOps Repositories

locals {
  repository_ids = { for key, repo in azuredevops_git_repository.repo : key => repo.id }
}

resource "azuredevops_git_repository" "repo" {
  for_each = var.repositories

  project_id           = var.project_id
  name                 = coalesce(each.value.name, each.key)
  default_branch       = each.value.default_branch
  parent_repository_id = each.value.parent_repository_id
  disabled             = each.value.disabled

  initialization {
    init_type             = each.value.initialization.init_type
    source_type           = each.value.initialization.source_type
    source_url            = each.value.initialization.source_url
    service_connection_id = each.value.initialization.service_connection_id
    username              = each.value.initialization.username
    password              = each.value.initialization.password
  }
}

resource "azuredevops_git_repository_branch" "branch" {
  for_each = { for index, branch in var.branches : index => branch }

  repository_id = each.value.repository_id != null ? each.value.repository_id : local.repository_ids[each.value.repository_key]
  name          = each.value.name
  ref_branch    = each.value.ref_branch
  ref_tag       = each.value.ref_tag
  ref_commit_id = each.value.ref_commit_id
}

resource "azuredevops_git_repository_file" "file" {
  for_each = { for index, file in var.files : index => file }

  repository_id       = each.value.repository_id != null ? each.value.repository_id : local.repository_ids[each.value.repository_key]
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

resource "azuredevops_git_permissions" "permissions" {
  for_each = { for index, perm in var.git_permissions : index => perm }

  project_id    = var.project_id
  repository_id = each.value.repository_id != null ? each.value.repository_id : (each.value.repository_key != null ? local.repository_ids[each.value.repository_key] : null)
  branch_name   = each.value.branch_name
  principal     = each.value.principal
  permissions   = each.value.permissions
  replace       = each.value.replace
}

resource "azuredevops_branch_policy_auto_reviewers" "policy" {
  for_each = { for index, policy in var.branch_policy_auto_reviewers : index => policy }

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
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : (scope.value.repository_key != null ? local.repository_ids[scope.value.repository_key] : null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }
}

resource "azuredevops_branch_policy_build_validation" "policy" {
  for_each = { for index, policy in var.branch_policy_build_validation : index => policy }

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
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : (scope.value.repository_key != null ? local.repository_ids[scope.value.repository_key] : null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }
}

resource "azuredevops_branch_policy_comment_resolution" "policy" {
  for_each = { for index, policy in var.branch_policy_comment_resolution : index => policy }

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    dynamic "scope" {
      for_each = each.value.scope
      content {
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : (scope.value.repository_key != null ? local.repository_ids[scope.value.repository_key] : null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }
}

resource "azuredevops_branch_policy_merge_types" "policy" {
  for_each = { for index, policy in var.branch_policy_merge_types : index => policy }

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
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : (scope.value.repository_key != null ? local.repository_ids[scope.value.repository_key] : null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }
}

resource "azuredevops_branch_policy_min_reviewers" "policy" {
  for_each = { for index, policy in var.branch_policy_min_reviewers : index => policy }

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
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : (scope.value.repository_key != null ? local.repository_ids[scope.value.repository_key] : null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }
}

resource "azuredevops_branch_policy_status_check" "policy" {
  for_each = { for index, policy in var.branch_policy_status_check : index => policy }

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
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : (scope.value.repository_key != null ? local.repository_ids[scope.value.repository_key] : null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }
}

resource "azuredevops_branch_policy_work_item_linking" "policy" {
  for_each = { for index, policy in var.branch_policy_work_item_linking : index => policy }

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    dynamic "scope" {
      for_each = each.value.scope
      content {
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : (scope.value.repository_key != null ? local.repository_ids[scope.value.repository_key] : null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }
}

resource "azuredevops_repository_policy_author_email_pattern" "policy" {
  for_each = { for index, policy in var.repository_policy_author_email_pattern : index => policy }

  project_id            = var.project_id
  enabled               = each.value.enabled
  blocking              = each.value.blocking
  author_email_patterns = each.value.author_email_patterns
  repository_ids = length(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
    )) > 0 ? distinct(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
  )) : null
}

resource "azuredevops_repository_policy_case_enforcement" "policy" {
  for_each = { for index, policy in var.repository_policy_case_enforcement : index => policy }

  project_id              = var.project_id
  enabled                 = each.value.enabled
  blocking                = each.value.blocking
  enforce_consistent_case = each.value.enforce_consistent_case
  repository_ids = length(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
    )) > 0 ? distinct(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
  )) : null
}

resource "azuredevops_repository_policy_check_credentials" "policy" {
  for_each = { for index, policy in var.repository_policy_check_credentials : index => policy }

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking
  repository_ids = length(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
    )) > 0 ? distinct(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
  )) : null
}

resource "azuredevops_repository_policy_file_path_pattern" "policy" {
  for_each = { for index, policy in var.repository_policy_file_path_pattern : index => policy }

  project_id        = var.project_id
  enabled           = each.value.enabled
  blocking          = each.value.blocking
  filepath_patterns = each.value.filepath_patterns
  repository_ids = length(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
    )) > 0 ? distinct(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
  )) : null
}

resource "azuredevops_repository_policy_max_file_size" "policy" {
  for_each = { for index, policy in var.repository_policy_max_file_size : index => policy }

  project_id    = var.project_id
  enabled       = each.value.enabled
  blocking      = each.value.blocking
  max_file_size = each.value.max_file_size
  repository_ids = length(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
    )) > 0 ? distinct(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
  )) : null
}

resource "azuredevops_repository_policy_max_path_length" "policy" {
  for_each = { for index, policy in var.repository_policy_max_path_length : index => policy }

  project_id      = var.project_id
  enabled         = each.value.enabled
  blocking        = each.value.blocking
  max_path_length = each.value.max_path_length
  repository_ids = length(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
    )) > 0 ? distinct(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
  )) : null
}

resource "azuredevops_repository_policy_reserved_names" "policy" {
  for_each = { for index, policy in var.repository_policy_reserved_names : index => policy }

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking
  repository_ids = length(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
    )) > 0 ? distinct(concat(
    try(each.value.repository_ids, []),
    [for key in try(each.value.repository_keys, []) : local.repository_ids[key]]
  )) : null
}
