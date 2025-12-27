# -----------------------------------------------------------------------------
# Core
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# Repositories
# -----------------------------------------------------------------------------

variable "repositories" {
  description = "Map of Git repositories to manage."
  type = map(object({
    name                 = optional(string)
    default_branch       = optional(string)
    parent_repository_id = optional(string)
    disabled             = optional(bool)
    initialization = optional(object({
      init_type             = optional(string, "Uninitialized")
      source_type           = optional(string)
      source_url            = optional(string)
      service_connection_id = optional(string)
      username              = optional(string)
      password              = optional(string)
    }), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for repo in values(var.repositories) : (
        repo.name == null || length(trimspace(repo.name)) > 0
      )
    ])
    error_message = "repositories.name must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repositories) : (
        repo.default_branch == null || length(trimspace(repo.default_branch)) > 0
      )
    ])
    error_message = "repositories.default_branch must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repositories) : (
        repo.default_branch == null || startswith(repo.default_branch, "refs/heads/")
      )
    ])
    error_message = "repositories.default_branch must start with refs/heads/."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repositories) : contains([
        "Uninitialized",
        "Clean",
        "Import",
      ], coalesce(try(repo.initialization.init_type, null), "Uninitialized"))
    ])
    error_message = "repositories.initialization.init_type must be Uninitialized, Clean, or Import."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repositories) : (
        try(repo.initialization.source_type, null) == null || try(repo.initialization.source_type, null) == "Git"
      )
    ])
    error_message = "repositories.initialization.source_type must be Git when provided."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repositories) : (
        coalesce(try(repo.initialization.init_type, null), "Uninitialized") != "Import" || (
          try(repo.initialization.source_url, null) != null && length(trimspace(try(repo.initialization.source_url, ""))) > 0
        )
      )
    ])
    error_message = "repositories.initialization.source_url is required when init_type is Import."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repositories) : (
        coalesce(try(repo.initialization.init_type, null), "Uninitialized") != "Import" || (
          (
            try(repo.initialization.service_connection_id, null) != null &&
            length(trimspace(try(repo.initialization.service_connection_id, ""))) > 0 &&
            try(repo.initialization.username, null) == null &&
            try(repo.initialization.password, null) == null
            ) || (
            try(repo.initialization.service_connection_id, null) == null &&
            try(repo.initialization.username, null) != null &&
            length(trimspace(try(repo.initialization.username, ""))) > 0 &&
            try(repo.initialization.password, null) != null &&
            length(trimspace(try(repo.initialization.password, ""))) > 0
          )
        )
      )
    ])
    error_message = "repositories.initialization Import requires service_connection_id or username/password (exactly one)."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repositories) : (
        coalesce(try(repo.initialization.init_type, null), "Uninitialized") == "Import" || (
          try(repo.initialization.source_type, null) == null &&
          try(repo.initialization.source_url, null) == null &&
          try(repo.initialization.service_connection_id, null) == null &&
          try(repo.initialization.username, null) == null &&
          try(repo.initialization.password, null) == null
        )
      )
    ])
    error_message = "repositories.initialization import fields are only allowed when init_type is Import."
  }
}

# -----------------------------------------------------------------------------
# Branches
# -----------------------------------------------------------------------------

variable "branches" {
  description = "List of Git repository branches to manage."
  type = list(object({
    key            = optional(string)
    repository_id  = optional(string)
    repository_key = optional(string)
    name           = string
    ref_branch     = optional(string)
    ref_tag        = optional(string)
    ref_commit_id  = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for branch in var.branches : (
        branch.key == null || length(trimspace(branch.key)) > 0
      )
    ])
    error_message = "branches.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : (
        (branch.repository_id != null) != (branch.repository_key != null)
      )
    ])
    error_message = "branches must set exactly one of repository_id or repository_key."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : (
        branch.repository_key == null || contains(keys(var.repositories), branch.repository_key)
      )
    ])
    error_message = "branches.repository_key must reference a key in repositories."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : length(trimspace(branch.name)) > 0
    ])
    error_message = "branches.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : (
        length(compact([
          branch.ref_branch,
          branch.ref_tag,
          branch.ref_commit_id,
        ])) <= 1
      )
    ])
    error_message = "branches may set only one of ref_branch, ref_tag, or ref_commit_id."
  }

  validation {
    condition = length(distinct([
      for branch in var.branches : coalesce(
        branch.key,
        format(
          "%s:%s",
          coalesce(branch.repository_key, branch.repository_id, "missing"),
          branch.name
        )
      )
    ])) == length(var.branches)
    error_message = "branches keys must be unique; set key when repository/name pairs would collide."
  }
}

# -----------------------------------------------------------------------------
# Files
# -----------------------------------------------------------------------------

variable "files" {
  description = "List of Git repository files to manage."
  type = list(object({
    key                 = optional(string)
    repository_id       = optional(string)
    repository_key      = optional(string)
    file                = string
    content             = string
    branch              = optional(string)
    commit_message      = optional(string)
    overwrite_on_create = optional(bool)
    author_name         = optional(string)
    author_email        = optional(string)
    committer_name      = optional(string)
    committer_email     = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for file in var.files : (
        file.key == null || length(trimspace(file.key)) > 0
      )
    ])
    error_message = "files.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for file in var.files : (
        (file.repository_id != null) != (file.repository_key != null)
      )
    ])
    error_message = "files must set exactly one of repository_id or repository_key."
  }

  validation {
    condition = alltrue([
      for file in var.files : (
        file.repository_key == null || contains(keys(var.repositories), file.repository_key)
      )
    ])
    error_message = "files.repository_key must reference a key in repositories."
  }

  validation {
    condition = alltrue([
      for file in var.files : length(trimspace(file.file)) > 0
    ])
    error_message = "files.file must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for file in var.files : length(file.content) > 0
    ])
    error_message = "files.content must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for file in var.files : (
        file.commit_message == null || length(trimspace(file.commit_message)) > 0
      )
    ])
    error_message = "files.commit_message must be a non-empty string when provided."
  }

  validation {
    condition = length(distinct([
      for file in var.files : coalesce(
        file.key,
        format(
          "%s:%s:%s",
          coalesce(file.repository_key, file.repository_id, "missing"),
          file.file,
          coalesce(file.branch, "default")
        )
      )
    ])) == length(var.files)
    error_message = "files keys must be unique; set key when repository/file/branch would collide."
  }
}

# -----------------------------------------------------------------------------
# Git Permissions
# -----------------------------------------------------------------------------

variable "git_permissions" {
  description = "List of Git permissions to assign."
  type = list(object({
    key            = optional(string)
    repository_id  = optional(string)
    repository_key = optional(string)
    branch_name    = optional(string)
    principal      = string
    permissions    = map(string)
    replace        = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.git_permissions : (
        perm.key == null || length(trimspace(perm.key)) > 0
      )
    ])
    error_message = "git_permissions.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.git_permissions : (
        (perm.repository_id != null) != (perm.repository_key != null)
      )
    ])
    error_message = "git_permissions must set exactly one of repository_id or repository_key."
  }

  validation {
    condition = alltrue([
      for perm in var.git_permissions : (
        perm.repository_key == null || contains(keys(var.repositories), perm.repository_key)
      )
    ])
    error_message = "git_permissions.repository_key must reference a key in repositories."
  }

  validation {
    condition = alltrue([
      for perm in var.git_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "git_permissions.principal must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for perm in var.git_permissions : alltrue([
        for status in values(perm.permissions) : contains(["Allow", "Deny", "NotSet"], status)
      ])
    ])
    error_message = "git_permissions.permissions values must be one of: Allow, Deny, NotSet."
  }

  validation {
    condition = length(distinct([
      for perm in var.git_permissions : coalesce(
        perm.key,
        format(
          "%s:%s:%s",
          coalesce(perm.repository_key, perm.repository_id, "missing"),
          coalesce(perm.branch_name, "root"),
          perm.principal
        )
      )
    ])) == length(var.git_permissions)
    error_message = "git_permissions keys must be unique; set key when repository/branch/principal would collide."
  }
}

# -----------------------------------------------------------------------------
# Branch Policies - Auto Reviewers
# -----------------------------------------------------------------------------

variable "branch_policy_auto_reviewers" {
  description = "List of auto reviewer branch policies."
  type = list(object({
    key                         = optional(string)
    enabled                     = optional(bool)
    blocking                    = optional(bool)
    auto_reviewer_ids           = list(string)
    path_filters                = optional(list(string))
    submitter_can_vote          = optional(bool)
    message                     = optional(string)
    minimum_number_of_reviewers = optional(number)
    scope = list(object({
      repository_id  = optional(string)
      repository_key = optional(string)
      repository_ref = optional(string)
      match_type     = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.branch_policy_auto_reviewers : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "branch_policy_auto_reviewers.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_auto_reviewers : length(policy.auto_reviewer_ids) > 0
    ])
    error_message = "branch_policy_auto_reviewers.auto_reviewer_ids must not be empty."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_auto_reviewers : length(policy.scope) > 0
    ])
    error_message = "branch_policy_auto_reviewers.scope must not be empty."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_auto_reviewers : alltrue([
        for scope in policy.scope : (
          (scope.repository_id != null) != (scope.repository_key != null)
        )
      ])
    ])
    error_message = "branch_policy_auto_reviewers.scope must set exactly one of repository_id or repository_key."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_auto_reviewers : alltrue([
        for scope in policy.scope : (
          scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
        )
      ])
    ])
    error_message = "branch_policy_auto_reviewers.scope.repository_key must reference a key in repositories."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_auto_reviewers : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || contains(["DefaultBranch", "Exact", "Prefix"], scope.match_type)
        )
      ])
    ])
    error_message = "branch_policy_auto_reviewers.scope.match_type must be DefaultBranch, Exact, or Prefix when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_auto_reviewers : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || scope.match_type == "DefaultBranch" || (
            scope.repository_ref != null && length(trimspace(scope.repository_ref)) > 0
          )
        )
      ])
    ])
    error_message = "branch_policy_auto_reviewers.scope.repository_ref is required when match_type is Exact or Prefix."
  }

  validation {
    condition = length(distinct([
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
      )
    ])) == length(var.branch_policy_auto_reviewers)
    error_message = "branch_policy_auto_reviewers keys must be unique; set key when scopes would collide."
  }
}

# -----------------------------------------------------------------------------
# Branch Policies - Build Validation
# -----------------------------------------------------------------------------

variable "branch_policy_build_validation" {
  description = "List of build validation branch policies."
  type = list(object({
    key                         = optional(string)
    enabled                     = optional(bool)
    blocking                    = optional(bool)
    build_definition_id         = string
    display_name                = string
    manual_queue_only           = optional(bool)
    queue_on_source_update_only = optional(bool)
    valid_duration              = optional(number)
    filename_patterns           = optional(list(string))
    scope = list(object({
      repository_id  = optional(string)
      repository_key = optional(string)
      repository_ref = optional(string)
      match_type     = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.branch_policy_build_validation : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "branch_policy_build_validation.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_build_validation : (
        length(trimspace(policy.build_definition_id)) > 0 && length(trimspace(policy.display_name)) > 0
      )
    ])
    error_message = "branch_policy_build_validation.build_definition_id and display_name must be non-empty strings."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_build_validation : (
        policy.valid_duration == null || policy.valid_duration >= 0
      )
    ])
    error_message = "branch_policy_build_validation.valid_duration must be 0 or greater when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_build_validation : length(policy.scope) > 0
    ])
    error_message = "branch_policy_build_validation.scope must not be empty."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_build_validation : alltrue([
        for scope in policy.scope : (
          (scope.repository_id != null) != (scope.repository_key != null)
        )
      ])
    ])
    error_message = "branch_policy_build_validation.scope must set exactly one of repository_id or repository_key."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_build_validation : alltrue([
        for scope in policy.scope : (
          scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
        )
      ])
    ])
    error_message = "branch_policy_build_validation.scope.repository_key must reference a key in repositories."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_build_validation : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || contains(["DefaultBranch", "Exact", "Prefix"], scope.match_type)
        )
      ])
    ])
    error_message = "branch_policy_build_validation.scope.match_type must be DefaultBranch, Exact, or Prefix when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_build_validation : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || scope.match_type == "DefaultBranch" || (
            scope.repository_ref != null && length(trimspace(scope.repository_ref)) > 0
          )
        )
      ])
    ])
    error_message = "branch_policy_build_validation.scope.repository_ref is required when match_type is Exact or Prefix."
  }

  validation {
    condition = length(distinct([
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
      )
    ])) == length(var.branch_policy_build_validation)
    error_message = "branch_policy_build_validation keys must be unique; set key when scopes would collide."
  }
}

# -----------------------------------------------------------------------------
# Branch Policies - Comment Resolution
# -----------------------------------------------------------------------------

variable "branch_policy_comment_resolution" {
  description = "List of comment resolution branch policies."
  type = list(object({
    key      = optional(string)
    enabled  = optional(bool)
    blocking = optional(bool)
    scope = list(object({
      repository_id  = optional(string)
      repository_key = optional(string)
      repository_ref = optional(string)
      match_type     = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.branch_policy_comment_resolution : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "branch_policy_comment_resolution.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_comment_resolution : length(policy.scope) > 0
    ])
    error_message = "branch_policy_comment_resolution.scope must not be empty."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_comment_resolution : alltrue([
        for scope in policy.scope : (
          (scope.repository_id != null) != (scope.repository_key != null)
        )
      ])
    ])
    error_message = "branch_policy_comment_resolution.scope must set exactly one of repository_id or repository_key."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_comment_resolution : alltrue([
        for scope in policy.scope : (
          scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
        )
      ])
    ])
    error_message = "branch_policy_comment_resolution.scope.repository_key must reference a key in repositories."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_comment_resolution : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || contains(["DefaultBranch", "Exact", "Prefix"], scope.match_type)
        )
      ])
    ])
    error_message = "branch_policy_comment_resolution.scope.match_type must be DefaultBranch, Exact, or Prefix when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_comment_resolution : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || scope.match_type == "DefaultBranch" || (
            scope.repository_ref != null && length(trimspace(scope.repository_ref)) > 0
          )
        )
      ])
    ])
    error_message = "branch_policy_comment_resolution.scope.repository_ref is required when match_type is Exact or Prefix."
  }

  validation {
    condition = length(distinct([
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
      )
    ])) == length(var.branch_policy_comment_resolution)
    error_message = "branch_policy_comment_resolution keys must be unique; set key when scopes would collide."
  }
}

# -----------------------------------------------------------------------------
# Branch Policies - Merge Types
# -----------------------------------------------------------------------------

variable "branch_policy_merge_types" {
  description = "List of merge types branch policies."
  type = list(object({
    key                           = optional(string)
    enabled                       = optional(bool)
    blocking                      = optional(bool)
    allow_squash                  = optional(bool)
    allow_rebase_and_fast_forward = optional(bool)
    allow_basic_no_fast_forward   = optional(bool)
    allow_rebase_with_merge       = optional(bool)
    scope = list(object({
      repository_id  = optional(string)
      repository_key = optional(string)
      repository_ref = optional(string)
      match_type     = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.branch_policy_merge_types : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "branch_policy_merge_types.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_merge_types : length(policy.scope) > 0
    ])
    error_message = "branch_policy_merge_types.scope must not be empty."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_merge_types : alltrue([
        for scope in policy.scope : (
          (scope.repository_id != null) != (scope.repository_key != null)
        )
      ])
    ])
    error_message = "branch_policy_merge_types.scope must set exactly one of repository_id or repository_key."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_merge_types : alltrue([
        for scope in policy.scope : (
          scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
        )
      ])
    ])
    error_message = "branch_policy_merge_types.scope.repository_key must reference a key in repositories."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_merge_types : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || contains(["DefaultBranch", "Exact", "Prefix"], scope.match_type)
        )
      ])
    ])
    error_message = "branch_policy_merge_types.scope.match_type must be DefaultBranch, Exact, or Prefix when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_merge_types : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || scope.match_type == "DefaultBranch" || (
            scope.repository_ref != null && length(trimspace(scope.repository_ref)) > 0
          )
        )
      ])
    ])
    error_message = "branch_policy_merge_types.scope.repository_ref is required when match_type is Exact or Prefix."
  }

  validation {
    condition = length(distinct([
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
      )
    ])) == length(var.branch_policy_merge_types)
    error_message = "branch_policy_merge_types keys must be unique; set key when scopes would collide."
  }
}

# -----------------------------------------------------------------------------
# Branch Policies - Minimum Reviewers
# -----------------------------------------------------------------------------

variable "branch_policy_min_reviewers" {
  description = "List of minimum reviewers branch policies."
  type = list(object({
    key                                    = optional(string)
    enabled                                = optional(bool)
    blocking                               = optional(bool)
    reviewer_count                         = number
    submitter_can_vote                     = optional(bool)
    last_pusher_cannot_approve             = optional(bool)
    allow_completion_with_rejects_or_waits = optional(bool)
    on_push_reset_approved_votes           = optional(bool)
    on_push_reset_all_votes                = optional(bool)
    on_last_iteration_require_vote         = optional(bool)
    scope = list(object({
      repository_id  = optional(string)
      repository_key = optional(string)
      repository_ref = optional(string)
      match_type     = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.branch_policy_min_reviewers : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "branch_policy_min_reviewers.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_min_reviewers : policy.reviewer_count > 0
    ])
    error_message = "branch_policy_min_reviewers.reviewer_count must be greater than 0."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_min_reviewers : length(policy.scope) > 0
    ])
    error_message = "branch_policy_min_reviewers.scope must not be empty."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_min_reviewers : alltrue([
        for scope in policy.scope : (
          (scope.repository_id != null) != (scope.repository_key != null)
        )
      ])
    ])
    error_message = "branch_policy_min_reviewers.scope must set exactly one of repository_id or repository_key."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_min_reviewers : alltrue([
        for scope in policy.scope : (
          scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
        )
      ])
    ])
    error_message = "branch_policy_min_reviewers.scope.repository_key must reference a key in repositories."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_min_reviewers : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || contains(["DefaultBranch", "Exact", "Prefix"], scope.match_type)
        )
      ])
    ])
    error_message = "branch_policy_min_reviewers.scope.match_type must be DefaultBranch, Exact, or Prefix when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_min_reviewers : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || scope.match_type == "DefaultBranch" || (
            scope.repository_ref != null && length(trimspace(scope.repository_ref)) > 0
          )
        )
      ])
    ])
    error_message = "branch_policy_min_reviewers.scope.repository_ref is required when match_type is Exact or Prefix."
  }

  validation {
    condition = length(distinct([
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
      )
    ])) == length(var.branch_policy_min_reviewers)
    error_message = "branch_policy_min_reviewers keys must be unique; set key when scopes would collide."
  }
}

# -----------------------------------------------------------------------------
# Branch Policies - Status Check
# -----------------------------------------------------------------------------

variable "branch_policy_status_check" {
  description = "List of status check branch policies."
  type = list(object({
    key                  = optional(string)
    enabled              = optional(bool)
    blocking             = optional(bool)
    name                 = string
    genre                = optional(string)
    author_id            = optional(string)
    invalidate_on_update = optional(bool)
    applicability        = optional(string)
    filename_patterns    = optional(list(string))
    display_name         = optional(string)
    scope = list(object({
      repository_id  = optional(string)
      repository_key = optional(string)
      repository_ref = optional(string)
      match_type     = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.branch_policy_status_check : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "branch_policy_status_check.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_status_check : length(trimspace(policy.name)) > 0
    ])
    error_message = "branch_policy_status_check.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_status_check : (
        policy.display_name == null || length(trimspace(policy.display_name)) > 0
      )
    ])
    error_message = "branch_policy_status_check.display_name must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_status_check : length(policy.scope) > 0
    ])
    error_message = "branch_policy_status_check.scope must not be empty."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_status_check : alltrue([
        for scope in policy.scope : (
          (scope.repository_id != null) != (scope.repository_key != null)
        )
      ])
    ])
    error_message = "branch_policy_status_check.scope must set exactly one of repository_id or repository_key."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_status_check : alltrue([
        for scope in policy.scope : (
          scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
        )
      ])
    ])
    error_message = "branch_policy_status_check.scope.repository_key must reference a key in repositories."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_status_check : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || contains(["DefaultBranch", "Exact", "Prefix"], scope.match_type)
        )
      ])
    ])
    error_message = "branch_policy_status_check.scope.match_type must be DefaultBranch, Exact, or Prefix when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_status_check : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || scope.match_type == "DefaultBranch" || (
            scope.repository_ref != null && length(trimspace(scope.repository_ref)) > 0
          )
        )
      ])
    ])
    error_message = "branch_policy_status_check.scope.repository_ref is required when match_type is Exact or Prefix."
  }

  validation {
    condition = length(distinct([
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
      )
    ])) == length(var.branch_policy_status_check)
    error_message = "branch_policy_status_check keys must be unique; set key when scopes would collide."
  }
}

# -----------------------------------------------------------------------------
# Branch Policies - Work Item Linking
# -----------------------------------------------------------------------------

variable "branch_policy_work_item_linking" {
  description = "List of work item linking branch policies."
  type = list(object({
    key      = optional(string)
    enabled  = optional(bool)
    blocking = optional(bool)
    scope = list(object({
      repository_id  = optional(string)
      repository_key = optional(string)
      repository_ref = optional(string)
      match_type     = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.branch_policy_work_item_linking : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "branch_policy_work_item_linking.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_work_item_linking : length(policy.scope) > 0
    ])
    error_message = "branch_policy_work_item_linking.scope must not be empty."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_work_item_linking : alltrue([
        for scope in policy.scope : (
          (scope.repository_id != null) != (scope.repository_key != null)
        )
      ])
    ])
    error_message = "branch_policy_work_item_linking.scope must set exactly one of repository_id or repository_key."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_work_item_linking : alltrue([
        for scope in policy.scope : (
          scope.repository_key == null || contains(keys(var.repositories), scope.repository_key)
        )
      ])
    ])
    error_message = "branch_policy_work_item_linking.scope.repository_key must reference a key in repositories."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_work_item_linking : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || contains(["DefaultBranch", "Exact", "Prefix"], scope.match_type)
        )
      ])
    ])
    error_message = "branch_policy_work_item_linking.scope.match_type must be DefaultBranch, Exact, or Prefix when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_work_item_linking : alltrue([
        for scope in policy.scope : (
          scope.match_type == null || scope.match_type == "DefaultBranch" || (
            scope.repository_ref != null && length(trimspace(scope.repository_ref)) > 0
          )
        )
      ])
    ])
    error_message = "branch_policy_work_item_linking.scope.repository_ref is required when match_type is Exact or Prefix."
  }

  validation {
    condition = length(distinct([
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
      )
    ])) == length(var.branch_policy_work_item_linking)
    error_message = "branch_policy_work_item_linking keys must be unique; set key when scopes would collide."
  }
}

# -----------------------------------------------------------------------------
# Repository Policies - Author Email Pattern
# -----------------------------------------------------------------------------

variable "repository_policy_author_email_pattern" {
  description = "List of author email pattern repository policies."
  type = list(object({
    key                   = optional(string)
    enabled               = optional(bool)
    blocking              = optional(bool)
    author_email_patterns = list(string)
    repository_ids        = optional(list(string))
    repository_keys       = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.repository_policy_author_email_pattern : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "repository_policy_author_email_pattern.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_author_email_pattern : length(policy.author_email_patterns) > 0
    ])
    error_message = "repository_policy_author_email_pattern.author_email_patterns must not be empty."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_author_email_pattern : (
        length(coalesce(policy.repository_ids, [])) + length(coalesce(policy.repository_keys, [])) > 0
      )
    ])
    error_message = "repository_policy_author_email_pattern requires repository_ids or repository_keys."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_author_email_pattern : alltrue([
        for key in coalesce(policy.repository_keys, []) : contains(keys(var.repositories), key)
      ])
    ])
    error_message = "repository_policy_author_email_pattern.repository_keys must reference keys in repositories."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_author_email_pattern : coalesce(
        policy.key,
        format(
          "author_email_pattern:%s",
          join(",", sort(concat(
            [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
            [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
          )))
        )
      )
    ])) == length(var.repository_policy_author_email_pattern)
    error_message = "repository_policy_author_email_pattern keys must be unique; set key when repository targets would collide."
  }
}

# -----------------------------------------------------------------------------
# Repository Policies - Case Enforcement
# -----------------------------------------------------------------------------

variable "repository_policy_case_enforcement" {
  description = "List of case enforcement repository policies."
  type = list(object({
    key                     = optional(string)
    enabled                 = optional(bool)
    blocking                = optional(bool)
    enforce_consistent_case = bool
    repository_ids          = optional(list(string))
    repository_keys         = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.repository_policy_case_enforcement : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "repository_policy_case_enforcement.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_case_enforcement : (
        length(coalesce(policy.repository_ids, [])) + length(coalesce(policy.repository_keys, [])) > 0
      )
    ])
    error_message = "repository_policy_case_enforcement requires repository_ids or repository_keys."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_case_enforcement : alltrue([
        for key in coalesce(policy.repository_keys, []) : contains(keys(var.repositories), key)
      ])
    ])
    error_message = "repository_policy_case_enforcement.repository_keys must reference keys in repositories."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_case_enforcement : coalesce(
        policy.key,
        format(
          "case_enforcement:%s",
          join(",", sort(concat(
            [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
            [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
          )))
        )
      )
    ])) == length(var.repository_policy_case_enforcement)
    error_message = "repository_policy_case_enforcement keys must be unique; set key when repository targets would collide."
  }
}

# -----------------------------------------------------------------------------
# Repository Policies - File Path Pattern
# -----------------------------------------------------------------------------

variable "repository_policy_file_path_pattern" {
  description = "List of file path pattern repository policies."
  type = list(object({
    key               = optional(string)
    enabled           = optional(bool)
    blocking          = optional(bool)
    filepath_patterns = list(string)
    repository_ids    = optional(list(string))
    repository_keys   = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.repository_policy_file_path_pattern : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "repository_policy_file_path_pattern.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_file_path_pattern : length(policy.filepath_patterns) > 0
    ])
    error_message = "repository_policy_file_path_pattern.filepath_patterns must not be empty."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_file_path_pattern : (
        length(coalesce(policy.repository_ids, [])) + length(coalesce(policy.repository_keys, [])) > 0
      )
    ])
    error_message = "repository_policy_file_path_pattern requires repository_ids or repository_keys."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_file_path_pattern : alltrue([
        for key in coalesce(policy.repository_keys, []) : contains(keys(var.repositories), key)
      ])
    ])
    error_message = "repository_policy_file_path_pattern.repository_keys must reference keys in repositories."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_file_path_pattern : coalesce(
        policy.key,
        format(
          "file_path_pattern:%s",
          join(",", sort(concat(
            [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
            [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
          )))
        )
      )
    ])) == length(var.repository_policy_file_path_pattern)
    error_message = "repository_policy_file_path_pattern keys must be unique; set key when repository targets would collide."
  }
}

# -----------------------------------------------------------------------------
# Repository Policies - Max File Size
# -----------------------------------------------------------------------------

variable "repository_policy_max_file_size" {
  description = "List of max file size repository policies."
  type = list(object({
    key             = optional(string)
    enabled         = optional(bool)
    blocking        = optional(bool)
    max_file_size   = number
    repository_ids  = optional(list(string))
    repository_keys = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.repository_policy_max_file_size : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "repository_policy_max_file_size.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_max_file_size : policy.max_file_size > 0
    ])
    error_message = "repository_policy_max_file_size.max_file_size must be greater than 0."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_max_file_size : (
        length(coalesce(policy.repository_ids, [])) + length(coalesce(policy.repository_keys, [])) > 0
      )
    ])
    error_message = "repository_policy_max_file_size requires repository_ids or repository_keys."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_max_file_size : alltrue([
        for key in coalesce(policy.repository_keys, []) : contains(keys(var.repositories), key)
      ])
    ])
    error_message = "repository_policy_max_file_size.repository_keys must reference keys in repositories."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_max_file_size : coalesce(
        policy.key,
        format(
          "max_file_size:%s",
          join(",", sort(concat(
            [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
            [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
          )))
        )
      )
    ])) == length(var.repository_policy_max_file_size)
    error_message = "repository_policy_max_file_size keys must be unique; set key when repository targets would collide."
  }
}

# -----------------------------------------------------------------------------
# Repository Policies - Max Path Length
# -----------------------------------------------------------------------------

variable "repository_policy_max_path_length" {
  description = "List of max path length repository policies."
  type = list(object({
    key             = optional(string)
    enabled         = optional(bool)
    blocking        = optional(bool)
    max_path_length = number
    repository_ids  = optional(list(string))
    repository_keys = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.repository_policy_max_path_length : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "repository_policy_max_path_length.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_max_path_length : policy.max_path_length > 0
    ])
    error_message = "repository_policy_max_path_length.max_path_length must be greater than 0."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_max_path_length : (
        length(coalesce(policy.repository_ids, [])) + length(coalesce(policy.repository_keys, [])) > 0
      )
    ])
    error_message = "repository_policy_max_path_length requires repository_ids or repository_keys."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_max_path_length : alltrue([
        for key in coalesce(policy.repository_keys, []) : contains(keys(var.repositories), key)
      ])
    ])
    error_message = "repository_policy_max_path_length.repository_keys must reference keys in repositories."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_max_path_length : coalesce(
        policy.key,
        format(
          "max_path_length:%s",
          join(",", sort(concat(
            [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
            [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
          )))
        )
      )
    ])) == length(var.repository_policy_max_path_length)
    error_message = "repository_policy_max_path_length keys must be unique; set key when repository targets would collide."
  }
}

# -----------------------------------------------------------------------------
# Repository Policies - Reserved Names
# -----------------------------------------------------------------------------

variable "repository_policy_reserved_names" {
  description = "List of reserved names repository policies."
  type = list(object({
    key             = optional(string)
    enabled         = optional(bool)
    blocking        = optional(bool)
    repository_ids  = optional(list(string))
    repository_keys = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.repository_policy_reserved_names : (
        policy.key == null || length(trimspace(policy.key)) > 0
      )
    ])
    error_message = "repository_policy_reserved_names.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_reserved_names : (
        length(coalesce(policy.repository_ids, [])) + length(coalesce(policy.repository_keys, [])) > 0
      )
    ])
    error_message = "repository_policy_reserved_names requires repository_ids or repository_keys."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_reserved_names : alltrue([
        for key in coalesce(policy.repository_keys, []) : contains(keys(var.repositories), key)
      ])
    ])
    error_message = "repository_policy_reserved_names.repository_keys must reference keys in repositories."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_reserved_names : coalesce(
        policy.key,
        format(
          "reserved_names:%s",
          join(",", sort(concat(
            [for id in coalesce(policy.repository_ids, []) : "id:${id}"],
            [for key in coalesce(policy.repository_keys, []) : "key:${key}"]
          )))
        )
      )
    ])) == length(var.repository_policy_reserved_names)
    error_message = "repository_policy_reserved_names keys must be unique; set key when repository targets would collide."
  }
}
