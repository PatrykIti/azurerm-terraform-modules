# Azure DevOps Repositories

locals {
  repositories_normalized = {
    for key, repo in var.repositories : key => {
      name                 = coalesce(repo.name, key)
      default_branch       = repo.default_branch
      parent_repository_id = repo.parent_repository_id
      disabled             = repo.disabled
      initialization = {
        init_type = coalesce(try(repo.initialization.init_type, null), "Uninitialized")
        source_type = try(
          coalesce(
            try(repo.initialization.source_type, null),
            coalesce(try(repo.initialization.init_type, null), "Uninitialized") == "Import" ? "Git" : null
          ),
          null
        )
        source_url            = try(repo.initialization.source_url, null)
        service_connection_id = try(repo.initialization.service_connection_id, null)
        username              = try(repo.initialization.username, null)
        password              = try(repo.initialization.password, null)
      }
    }
  }

  branches_by_key = {
    for branch in var.branches : coalesce(
      branch.key,
      format(
        "%s:%s",
        coalesce(branch.repository_key, branch.repository_id, "missing"),
        branch.name
      )
    ) => branch
  }

  files_by_key = {
    for file in var.files : coalesce(
      file.key,
      format(
        "%s:%s:%s",
        coalesce(file.repository_key, file.repository_id, "missing"),
        file.file,
        coalesce(file.branch, "default")
      )
    ) => file
  }

  git_permissions_by_key = {
    for permission in var.git_permissions : coalesce(
      permission.key,
      format(
        "%s:%s:%s",
        coalesce(permission.repository_key, permission.repository_id, "missing"),
        coalesce(permission.branch_name, "root"),
        permission.principal
      )
    ) => permission
  }

  branch_policy_auto_reviewers_by_key = {
    for policy in var.branch_policy_auto_reviewers : coalesce(
      policy.key,
      format(
        "auto_reviewers:%s",
        coalesce(
          try(policy.scope[0].repository_key, null),
          try(policy.scope[0].repository_id, null),
          "missing"
        )
      )
    ) => policy
  }

  branch_policy_build_validation_by_key = {
    for policy in var.branch_policy_build_validation : coalesce(
      policy.key,
      format(
        "build_validation:%s",
        coalesce(
          try(policy.scope[0].repository_key, null),
          try(policy.scope[0].repository_id, null),
          "missing"
        )
      )
    ) => policy
  }

  branch_policy_comment_resolution_by_key = {
    for policy in var.branch_policy_comment_resolution : coalesce(
      policy.key,
      format(
        "comment_resolution:%s",
        coalesce(
          try(policy.scope[0].repository_key, null),
          try(policy.scope[0].repository_id, null),
          "missing"
        )
      )
    ) => policy
  }

  branch_policy_merge_types_by_key = {
    for policy in var.branch_policy_merge_types : coalesce(
      policy.key,
      format(
        "merge_types:%s",
        coalesce(
          try(policy.scope[0].repository_key, null),
          try(policy.scope[0].repository_id, null),
          "missing"
        )
      )
    ) => policy
  }

  branch_policy_min_reviewers_by_key = {
    for policy in var.branch_policy_min_reviewers : coalesce(
      policy.key,
      format(
        "min_reviewers:%s",
        coalesce(
          try(policy.scope[0].repository_key, null),
          try(policy.scope[0].repository_id, null),
          "missing"
        )
      )
    ) => policy
  }

  branch_policy_status_check_by_key = {
    for policy in var.branch_policy_status_check : coalesce(
      policy.key,
      format(
        "status_check:%s",
        coalesce(
          try(policy.scope[0].repository_key, null),
          try(policy.scope[0].repository_id, null),
          "missing"
        )
      )
    ) => policy
  }

  branch_policy_work_item_linking_by_key = {
    for policy in var.branch_policy_work_item_linking : coalesce(
      policy.key,
      format(
        "work_item_linking:%s",
        coalesce(
          try(policy.scope[0].repository_key, null),
          try(policy.scope[0].repository_id, null),
          "missing"
        )
      )
    ) => policy
  }

  repository_ids = { for key, repo in azuredevops_git_repository.repo : key => repo.id }

  repository_policy_author_email_pattern_by_key = {
    for policy in var.repository_policy_author_email_pattern : coalesce(
      policy.key,
      format(
        "author_email_pattern:%s",
        join(",", sort(concat(
          [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
          [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
        )))
      )
      ) => merge(policy, {
        repository_ids = distinct(compact(concat(
          coalesce(policy.repository_ids, []),
          [for key in coalesce(policy.repository_keys, []) : lookup(local.repository_ids, key, null)]
        )))
    })
  }

  repository_policy_case_enforcement_by_key = {
    for policy in var.repository_policy_case_enforcement : coalesce(
      policy.key,
      format(
        "case_enforcement:%s",
        join(",", sort(concat(
          [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
          [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
        )))
      )
      ) => merge(policy, {
        repository_ids = distinct(compact(concat(
          coalesce(policy.repository_ids, []),
          [for key in coalesce(policy.repository_keys, []) : lookup(local.repository_ids, key, null)]
        )))
    })
  }

  repository_policy_check_credentials_by_key = {
    for policy in var.repository_policy_check_credentials : coalesce(
      policy.key,
      format(
        "check_credentials:%s",
        join(",", sort(concat(
          [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
          [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
        )))
      )
      ) => merge(policy, {
        repository_ids = distinct(compact(concat(
          coalesce(policy.repository_ids, []),
          [for key in coalesce(policy.repository_keys, []) : lookup(local.repository_ids, key, null)]
        )))
    })
  }

  repository_policy_file_path_pattern_by_key = {
    for policy in var.repository_policy_file_path_pattern : coalesce(
      policy.key,
      format(
        "file_path_pattern:%s",
        join(",", sort(concat(
          [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
          [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
        )))
      )
      ) => merge(policy, {
        repository_ids = distinct(compact(concat(
          coalesce(policy.repository_ids, []),
          [for key in coalesce(policy.repository_keys, []) : lookup(local.repository_ids, key, null)]
        )))
    })
  }

  repository_policy_max_file_size_by_key = {
    for policy in var.repository_policy_max_file_size : coalesce(
      policy.key,
      format(
        "max_file_size:%s",
        join(",", sort(concat(
          [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
          [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
        )))
      )
      ) => merge(policy, {
        repository_ids = distinct(compact(concat(
          coalesce(policy.repository_ids, []),
          [for key in coalesce(policy.repository_keys, []) : lookup(local.repository_ids, key, null)]
        )))
    })
  }

  repository_policy_max_path_length_by_key = {
    for policy in var.repository_policy_max_path_length : coalesce(
      policy.key,
      format(
        "max_path_length:%s",
        join(",", sort(concat(
          [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
          [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
        )))
      )
      ) => merge(policy, {
        repository_ids = distinct(compact(concat(
          coalesce(policy.repository_ids, []),
          [for key in coalesce(policy.repository_keys, []) : lookup(local.repository_ids, key, null)]
        )))
    })
  }

  repository_policy_reserved_names_by_key = {
    for policy in var.repository_policy_reserved_names : coalesce(
      policy.key,
      format(
        "reserved_names:%s",
        join(",", sort(concat(
          [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
          [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
        )))
      )
      ) => merge(policy, {
        repository_ids = distinct(compact(concat(
          coalesce(policy.repository_ids, []),
          [for key in coalesce(policy.repository_keys, []) : lookup(local.repository_ids, key, null)]
        )))
    })
  }
}

resource "azuredevops_git_repository" "repo" {
  for_each = local.repositories_normalized

  project_id           = var.project_id
  name                 = each.value.name
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
  for_each = local.branches_by_key

  repository_id = each.value.repository_id != null ? each.value.repository_id : lookup(local.repository_ids, each.value.repository_key, null)
  name          = each.value.name
  ref_branch    = each.value.ref_branch
  ref_tag       = each.value.ref_tag
  ref_commit_id = each.value.ref_commit_id

  lifecycle {
    precondition {
      condition     = each.value.repository_key == null || contains(keys(var.repositories), each.value.repository_key)
      error_message = "branches.repository_key must reference a key in repositories."
    }
  }
}

resource "azuredevops_git_repository_file" "file" {
  for_each = local.files_by_key

  repository_id       = each.value.repository_id != null ? each.value.repository_id : lookup(local.repository_ids, each.value.repository_key, null)
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
      condition     = each.value.repository_key == null || contains(keys(var.repositories), each.value.repository_key)
      error_message = "files.repository_key must reference a key in repositories."
    }
  }
}

resource "azuredevops_git_permissions" "permissions" {
  for_each = local.git_permissions_by_key

  project_id    = var.project_id
  repository_id = each.value.repository_id != null ? each.value.repository_id : lookup(local.repository_ids, each.value.repository_key, null)
  branch_name   = each.value.branch_name
  principal     = each.value.principal
  permissions   = each.value.permissions
  replace       = each.value.replace

  lifecycle {
    precondition {
      condition     = each.value.repository_key == null || contains(keys(var.repositories), each.value.repository_key)
      error_message = "git_permissions.repository_key must reference a key in repositories."
    }
  }
}

resource "azuredevops_branch_policy_auto_reviewers" "policy" {
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
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : lookup(local.repository_ids, scope.value.repository_key, null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for scope in each.value.scope : scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
      ])
      error_message = "branch_policy_auto_reviewers.scope.repository_key must reference a key in repositories."
    }
  }
}

resource "azuredevops_branch_policy_build_validation" "policy" {
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
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : lookup(local.repository_ids, scope.value.repository_key, null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for scope in each.value.scope : scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
      ])
      error_message = "branch_policy_build_validation.scope.repository_key must reference a key in repositories."
    }
  }
}

resource "azuredevops_branch_policy_comment_resolution" "policy" {
  for_each = local.branch_policy_comment_resolution_by_key

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    dynamic "scope" {
      for_each = each.value.scope
      content {
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : lookup(local.repository_ids, scope.value.repository_key, null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for scope in each.value.scope : scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
      ])
      error_message = "branch_policy_comment_resolution.scope.repository_key must reference a key in repositories."
    }
  }
}

resource "azuredevops_branch_policy_merge_types" "policy" {
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
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : lookup(local.repository_ids, scope.value.repository_key, null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for scope in each.value.scope : scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
      ])
      error_message = "branch_policy_merge_types.scope.repository_key must reference a key in repositories."
    }
  }
}

resource "azuredevops_branch_policy_min_reviewers" "policy" {
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
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : lookup(local.repository_ids, scope.value.repository_key, null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for scope in each.value.scope : scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
      ])
      error_message = "branch_policy_min_reviewers.scope.repository_key must reference a key in repositories."
    }
  }
}

resource "azuredevops_branch_policy_status_check" "policy" {
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
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : lookup(local.repository_ids, scope.value.repository_key, null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for scope in each.value.scope : scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
      ])
      error_message = "branch_policy_status_check.scope.repository_key must reference a key in repositories."
    }
  }
}

resource "azuredevops_branch_policy_work_item_linking" "policy" {
  for_each = local.branch_policy_work_item_linking_by_key

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    dynamic "scope" {
      for_each = each.value.scope
      content {
        repository_id  = scope.value.repository_id != null ? scope.value.repository_id : lookup(local.repository_ids, scope.value.repository_key, null)
        repository_ref = scope.value.repository_ref
        match_type     = scope.value.match_type
      }
    }
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for scope in each.value.scope : scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
      ])
      error_message = "branch_policy_work_item_linking.scope.repository_key must reference a key in repositories."
    }
  }
}

resource "azuredevops_repository_policy_author_email_pattern" "policy" {
  for_each = local.repository_policy_author_email_pattern_by_key

  project_id            = var.project_id
  enabled               = each.value.enabled
  blocking              = each.value.blocking
  author_email_patterns = each.value.author_email_patterns
  repository_ids        = each.value.repository_ids

  lifecycle {
    precondition {
      condition = alltrue([
        for key in coalesce(each.value.repository_keys, []) : contains(keys(var.repositories), key)
      ])
      error_message = "repository_policy_author_email_pattern.repository_keys must reference keys in repositories."
    }
  }
}

resource "azuredevops_repository_policy_case_enforcement" "policy" {
  for_each = local.repository_policy_case_enforcement_by_key

  project_id              = var.project_id
  enabled                 = each.value.enabled
  blocking                = each.value.blocking
  enforce_consistent_case = each.value.enforce_consistent_case
  repository_ids          = each.value.repository_ids

  lifecycle {
    precondition {
      condition = alltrue([
        for key in coalesce(each.value.repository_keys, []) : contains(keys(var.repositories), key)
      ])
      error_message = "repository_policy_case_enforcement.repository_keys must reference keys in repositories."
    }
  }
}

resource "azuredevops_repository_policy_check_credentials" "policy" {
  for_each = local.repository_policy_check_credentials_by_key

  project_id     = var.project_id
  enabled        = each.value.enabled
  blocking       = each.value.blocking
  repository_ids = each.value.repository_ids

  lifecycle {
    precondition {
      condition = alltrue([
        for key in coalesce(each.value.repository_keys, []) : contains(keys(var.repositories), key)
      ])
      error_message = "repository_policy_check_credentials.repository_keys must reference keys in repositories."
    }
  }
}

resource "azuredevops_repository_policy_file_path_pattern" "policy" {
  for_each = local.repository_policy_file_path_pattern_by_key

  project_id        = var.project_id
  enabled           = each.value.enabled
  blocking          = each.value.blocking
  filepath_patterns = each.value.filepath_patterns
  repository_ids    = each.value.repository_ids

  lifecycle {
    precondition {
      condition = alltrue([
        for key in coalesce(each.value.repository_keys, []) : contains(keys(var.repositories), key)
      ])
      error_message = "repository_policy_file_path_pattern.repository_keys must reference keys in repositories."
    }
  }
}

resource "azuredevops_repository_policy_max_file_size" "policy" {
  for_each = local.repository_policy_max_file_size_by_key

  project_id     = var.project_id
  enabled        = each.value.enabled
  blocking       = each.value.blocking
  max_file_size  = each.value.max_file_size
  repository_ids = each.value.repository_ids

  lifecycle {
    precondition {
      condition = alltrue([
        for key in coalesce(each.value.repository_keys, []) : contains(keys(var.repositories), key)
      ])
      error_message = "repository_policy_max_file_size.repository_keys must reference keys in repositories."
    }
  }
}

resource "azuredevops_repository_policy_max_path_length" "policy" {
  for_each = local.repository_policy_max_path_length_by_key

  project_id      = var.project_id
  enabled         = each.value.enabled
  blocking        = each.value.blocking
  max_path_length = each.value.max_path_length
  repository_ids  = each.value.repository_ids

  lifecycle {
    precondition {
      condition = alltrue([
        for key in coalesce(each.value.repository_keys, []) : contains(keys(var.repositories), key)
      ])
      error_message = "repository_policy_max_path_length.repository_keys must reference keys in repositories."
    }
  }
}

resource "azuredevops_repository_policy_reserved_names" "policy" {
  for_each = local.repository_policy_reserved_names_by_key

  project_id     = var.project_id
  enabled        = each.value.enabled
  blocking       = each.value.blocking
  repository_ids = each.value.repository_ids

  lifecycle {
    precondition {
      condition = alltrue([
        for key in coalesce(each.value.repository_keys, []) : contains(keys(var.repositories), key)
      ])
      error_message = "repository_policy_reserved_names.repository_keys must reference keys in repositories."
    }
  }
}
