# -----------------------------------------------------------------------------
# Core Repository Configuration
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string."
  }
}

variable "name" {
  description = "Name of the repository to create. When null, the module will not create a repository."
  type        = string
  default     = null

  validation {
    condition     = var.name == null || length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string when provided."
  }
}

variable "default_branch" {
  description = "Default branch ref for the repository (for example, refs/heads/main)."
  type        = string
  default     = null

  validation {
    condition     = var.default_branch == null || length(trimspace(var.default_branch)) > 0
    error_message = "default_branch must be a non-empty string when provided."
  }

  validation {
    condition     = var.default_branch == null || startswith(var.default_branch, "refs/heads/")
    error_message = "default_branch must start with refs/heads/."
  }
}

variable "parent_repository_id" {
  description = "Parent repository ID for forks."
  type        = string
  default     = null

  validation {
    condition     = var.parent_repository_id == null || length(trimspace(var.parent_repository_id)) > 0
    error_message = "parent_repository_id must be a non-empty string when provided."
  }
}

variable "disabled" {
  description = "Whether the repository is disabled."
  type        = bool
  default     = null
}

variable "initialization" {
  description = <<-EOT
    Repository initialization settings.
    - init_type: Uninitialized, Clean, Import
    - source_type: Git (required when init_type is Import)
    - source_url: required when init_type is Import
    - service_connection_id or username/password for Import auth
  EOT
  type = object({
    init_type             = optional(string, "Uninitialized")
    source_type           = optional(string)
    source_url            = optional(string)
    service_connection_id = optional(string)
    username              = optional(string)
    password              = optional(string)
  })
  default   = null
  sensitive = true

  validation {
    condition = var.initialization == null || contains(
      ["Uninitialized", "Clean", "Import"],
      coalesce(try(var.initialization.init_type, null), "Uninitialized")
    )
    error_message = "initialization.init_type must be Uninitialized, Clean, or Import."
  }

  validation {
    condition = var.initialization == null || (
      coalesce(try(var.initialization.init_type, null), "Uninitialized") == "Import"
      ? (try(var.initialization.source_type, null) == null || try(var.initialization.source_type, null) == "Git")
      : try(var.initialization.source_type, null) == null
    )
    error_message = "initialization.source_type must be Git when init_type is Import, and null otherwise."
  }

  validation {
    condition = var.initialization == null || (
      coalesce(try(var.initialization.init_type, null), "Uninitialized") == "Import"
      ? (
        try(var.initialization.source_url, null) != null &&
        length(trimspace(try(var.initialization.source_url, ""))) > 0
      )
      : try(var.initialization.source_url, null) == null
    )
    error_message = "initialization.source_url is required when init_type is Import and must be null otherwise."
  }

  validation {
    condition = var.initialization == null || (
      coalesce(try(var.initialization.init_type, null), "Uninitialized") == "Import"
      ? (
        (
          try(var.initialization.service_connection_id, null) != null &&
          length(trimspace(try(var.initialization.service_connection_id, ""))) > 0 &&
          try(var.initialization.username, null) == null &&
          try(var.initialization.password, null) == null
          ) || (
          try(var.initialization.service_connection_id, null) == null &&
          try(var.initialization.username, null) != null &&
          length(trimspace(try(var.initialization.username, ""))) > 0 &&
          try(var.initialization.password, null) != null &&
          length(trimspace(try(var.initialization.password, ""))) > 0
        )
      )
      : (
        try(var.initialization.service_connection_id, null) == null &&
        try(var.initialization.username, null) == null &&
        try(var.initialization.password, null) == null
      )
    )
    error_message = "initialization Import requires service_connection_id or username/password (exactly one), and auth fields are only allowed when init_type is Import."
  }
}

# -----------------------------------------------------------------------------
# Branches
# -----------------------------------------------------------------------------

variable "branches" {
  description = "List of Git repository branches to manage."
  type = list(object({
    key           = optional(string)
    repository_id = optional(string)
    name          = string
    ref_branch    = optional(string)
    ref_tag       = optional(string)
    ref_commit_id = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for branch in var.branches : branch.key == null || length(trimspace(branch.key)) > 0
    ])
    error_message = "branches.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : branch.repository_id == null || length(trimspace(branch.repository_id)) > 0
    ])
    error_message = "branches.repository_id must be a non-empty string when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for branch in var.branches : branch.repository_id != null
    ])
    error_message = "branches.repository_id is required when the module repository is not created."
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
        branch.ref_branch == null || length(trimspace(branch.ref_branch)) > 0
      )
    ])
    error_message = "branches.ref_branch must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : (
        branch.ref_tag == null || length(trimspace(branch.ref_tag)) > 0
      )
    ])
    error_message = "branches.ref_tag must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : (
        branch.ref_commit_id == null || length(trimspace(branch.ref_commit_id)) > 0
      )
    ])
    error_message = "branches.ref_commit_id must be a non-empty string when provided."
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
      for branch in var.branches : coalesce(branch.key, branch.name)
    ])) == length(var.branches)
    error_message = "branches keys must be unique; set key when branch names would collide."
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
      for file in var.files : file.key == null || length(trimspace(file.key)) > 0
    ])
    error_message = "files.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for file in var.files : file.repository_id == null || length(trimspace(file.repository_id)) > 0
    ])
    error_message = "files.repository_id must be a non-empty string when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for file in var.files : file.repository_id != null
    ])
    error_message = "files.repository_id is required when the module repository is not created."
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
        file.branch == null || length(trimspace(file.branch)) > 0
      )
    ])
    error_message = "files.branch must be a non-empty string when provided."
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
    condition = alltrue([
      for file in var.files : (
        file.author_name == null || length(trimspace(file.author_name)) > 0
      )
    ])
    error_message = "files.author_name must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for file in var.files : (
        file.author_email == null || length(trimspace(file.author_email)) > 0
      )
    ])
    error_message = "files.author_email must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for file in var.files : (
        file.committer_name == null || length(trimspace(file.committer_name)) > 0
      )
    ])
    error_message = "files.committer_name must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for file in var.files : (
        file.committer_email == null || length(trimspace(file.committer_email)) > 0
      )
    ])
    error_message = "files.committer_email must be a non-empty string when provided."
  }

  validation {
    condition = length(distinct([
      for file in var.files : coalesce(file.key, file.file)
    ])) == length(var.files)
    error_message = "files keys must be unique; set key when file paths would collide."
  }
}

# -----------------------------------------------------------------------------
# Git Permissions
# -----------------------------------------------------------------------------

variable "git_permissions" {
  description = "List of Git permissions to assign."
  type = list(object({
    key           = optional(string)
    repository_id = optional(string)
    branch_name   = optional(string)
    principal     = string
    permissions   = map(string)
    replace       = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.git_permissions : perm.key == null || length(trimspace(perm.key)) > 0
    ])
    error_message = "git_permissions.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.git_permissions : perm.repository_id == null || length(trimspace(perm.repository_id)) > 0
    ])
    error_message = "git_permissions.repository_id must be a non-empty string when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for perm in var.git_permissions : perm.repository_id != null
    ])
    error_message = "git_permissions.repository_id is required when the module repository is not created."
  }

  validation {
    condition = alltrue([
      for perm in var.git_permissions : length(trimspace(perm.principal)) > 0
    ])
    error_message = "git_permissions.principal must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for perm in var.git_permissions : (
        perm.branch_name == null || length(trimspace(perm.branch_name)) > 0
      )
    ])
    error_message = "git_permissions.branch_name must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for perm in var.git_permissions : length(perm.permissions) > 0
    ])
    error_message = "git_permissions.permissions must not be empty."
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
          "%s:%s",
          coalesce(perm.branch_name, "root"),
          perm.principal
        )
      )
    ])) == length(var.git_permissions)
    error_message = "git_permissions keys must be unique; set key when branch/principal would collide."
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
      for policy in var.branch_policy_auto_reviewers : alltrue([
        for reviewer_id in policy.auto_reviewer_ids : length(trimspace(reviewer_id)) > 0
      ])
    ])
    error_message = "branch_policy_auto_reviewers.auto_reviewer_ids must contain non-empty values."
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
          scope.repository_id == null || length(trimspace(scope.repository_id)) > 0
        )
      ])
    ])
    error_message = "branch_policy_auto_reviewers.scope.repository_id must be a non-empty string when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.branch_policy_auto_reviewers : alltrue([
        for scope in policy.scope : scope.repository_id != null
      ])
    ])
    error_message = "branch_policy_auto_reviewers.scope.repository_id is required when the module repository is not created."
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
    condition = alltrue([
      for policy in var.branch_policy_auto_reviewers : alltrue([
        for scope in policy.scope : (
          scope.repository_ref == null || length(trimspace(scope.repository_ref)) > 0
        )
      ])
    ])
    error_message = "branch_policy_auto_reviewers.scope.repository_ref must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_auto_reviewers : alltrue([
        for scope in policy.scope : (
          coalesce(scope.match_type, "DefaultBranch") != "DefaultBranch" || scope.repository_ref == null
        )
      ])
    ])
    error_message = "branch_policy_auto_reviewers.scope.repository_ref must be omitted when match_type is DefaultBranch."
  }

  validation {
    condition = length(distinct([
      for policy in var.branch_policy_auto_reviewers : coalesce(policy.key, "auto_reviewers")
    ])) == length(var.branch_policy_auto_reviewers)
    error_message = "branch_policy_auto_reviewers keys must be unique; set key when multiple policies are defined."
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
      for policy in var.branch_policy_build_validation : length(trimspace(policy.build_definition_id)) > 0
    ])
    error_message = "branch_policy_build_validation.build_definition_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_build_validation : length(trimspace(policy.display_name)) > 0
    ])
    error_message = "branch_policy_build_validation.display_name must be a non-empty string."
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
          scope.repository_id == null || length(trimspace(scope.repository_id)) > 0
        )
      ])
    ])
    error_message = "branch_policy_build_validation.scope.repository_id must be a non-empty string when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.branch_policy_build_validation : alltrue([
        for scope in policy.scope : scope.repository_id != null
      ])
    ])
    error_message = "branch_policy_build_validation.scope.repository_id is required when the module repository is not created."
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
    condition = alltrue([
      for policy in var.branch_policy_build_validation : alltrue([
        for scope in policy.scope : (
          scope.repository_ref == null || length(trimspace(scope.repository_ref)) > 0
        )
      ])
    ])
    error_message = "branch_policy_build_validation.scope.repository_ref must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_build_validation : alltrue([
        for scope in policy.scope : (
          coalesce(scope.match_type, "DefaultBranch") != "DefaultBranch" || scope.repository_ref == null
        )
      ])
    ])
    error_message = "branch_policy_build_validation.scope.repository_ref must be omitted when match_type is DefaultBranch."
  }

  validation {
    condition = length(distinct([
      for policy in var.branch_policy_build_validation : coalesce(policy.key, "build_validation")
    ])) == length(var.branch_policy_build_validation)
    error_message = "branch_policy_build_validation keys must be unique; set key when multiple policies are defined."
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
          scope.repository_id == null || length(trimspace(scope.repository_id)) > 0
        )
      ])
    ])
    error_message = "branch_policy_comment_resolution.scope.repository_id must be a non-empty string when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.branch_policy_comment_resolution : alltrue([
        for scope in policy.scope : scope.repository_id != null
      ])
    ])
    error_message = "branch_policy_comment_resolution.scope.repository_id is required when the module repository is not created."
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
    condition = alltrue([
      for policy in var.branch_policy_comment_resolution : alltrue([
        for scope in policy.scope : (
          scope.repository_ref == null || length(trimspace(scope.repository_ref)) > 0
        )
      ])
    ])
    error_message = "branch_policy_comment_resolution.scope.repository_ref must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_comment_resolution : alltrue([
        for scope in policy.scope : (
          coalesce(scope.match_type, "DefaultBranch") != "DefaultBranch" || scope.repository_ref == null
        )
      ])
    ])
    error_message = "branch_policy_comment_resolution.scope.repository_ref must be omitted when match_type is DefaultBranch."
  }

  validation {
    condition = length(distinct([
      for policy in var.branch_policy_comment_resolution : coalesce(policy.key, "comment_resolution")
    ])) == length(var.branch_policy_comment_resolution)
    error_message = "branch_policy_comment_resolution keys must be unique; set key when multiple policies are defined."
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
          scope.repository_id == null || length(trimspace(scope.repository_id)) > 0
        )
      ])
    ])
    error_message = "branch_policy_merge_types.scope.repository_id must be a non-empty string when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.branch_policy_merge_types : alltrue([
        for scope in policy.scope : scope.repository_id != null
      ])
    ])
    error_message = "branch_policy_merge_types.scope.repository_id is required when the module repository is not created."
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
    condition = alltrue([
      for policy in var.branch_policy_merge_types : alltrue([
        for scope in policy.scope : (
          scope.repository_ref == null || length(trimspace(scope.repository_ref)) > 0
        )
      ])
    ])
    error_message = "branch_policy_merge_types.scope.repository_ref must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_merge_types : alltrue([
        for scope in policy.scope : (
          coalesce(scope.match_type, "DefaultBranch") != "DefaultBranch" || scope.repository_ref == null
        )
      ])
    ])
    error_message = "branch_policy_merge_types.scope.repository_ref must be omitted when match_type is DefaultBranch."
  }

  validation {
    condition = length(distinct([
      for policy in var.branch_policy_merge_types : coalesce(policy.key, "merge_types")
    ])) == length(var.branch_policy_merge_types)
    error_message = "branch_policy_merge_types keys must be unique; set key when multiple policies are defined."
  }
}

# -----------------------------------------------------------------------------
# Branch Policies - Min Reviewers
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
          scope.repository_id == null || length(trimspace(scope.repository_id)) > 0
        )
      ])
    ])
    error_message = "branch_policy_min_reviewers.scope.repository_id must be a non-empty string when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.branch_policy_min_reviewers : alltrue([
        for scope in policy.scope : scope.repository_id != null
      ])
    ])
    error_message = "branch_policy_min_reviewers.scope.repository_id is required when the module repository is not created."
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
    condition = alltrue([
      for policy in var.branch_policy_min_reviewers : alltrue([
        for scope in policy.scope : (
          scope.repository_ref == null || length(trimspace(scope.repository_ref)) > 0
        )
      ])
    ])
    error_message = "branch_policy_min_reviewers.scope.repository_ref must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_min_reviewers : alltrue([
        for scope in policy.scope : (
          coalesce(scope.match_type, "DefaultBranch") != "DefaultBranch" || scope.repository_ref == null
        )
      ])
    ])
    error_message = "branch_policy_min_reviewers.scope.repository_ref must be omitted when match_type is DefaultBranch."
  }

  validation {
    condition = length(distinct([
      for policy in var.branch_policy_min_reviewers : coalesce(policy.key, "min_reviewers")
    ])) == length(var.branch_policy_min_reviewers)
    error_message = "branch_policy_min_reviewers keys must be unique; set key when multiple policies are defined."
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
        policy.genre == null || length(trimspace(policy.genre)) > 0
      )
    ])
    error_message = "branch_policy_status_check.genre must be a non-empty string when provided."
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
          scope.repository_id == null || length(trimspace(scope.repository_id)) > 0
        )
      ])
    ])
    error_message = "branch_policy_status_check.scope.repository_id must be a non-empty string when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.branch_policy_status_check : alltrue([
        for scope in policy.scope : scope.repository_id != null
      ])
    ])
    error_message = "branch_policy_status_check.scope.repository_id is required when the module repository is not created."
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
    condition = alltrue([
      for policy in var.branch_policy_status_check : alltrue([
        for scope in policy.scope : (
          scope.repository_ref == null || length(trimspace(scope.repository_ref)) > 0
        )
      ])
    ])
    error_message = "branch_policy_status_check.scope.repository_ref must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_status_check : alltrue([
        for scope in policy.scope : (
          coalesce(scope.match_type, "DefaultBranch") != "DefaultBranch" || scope.repository_ref == null
        )
      ])
    ])
    error_message = "branch_policy_status_check.scope.repository_ref must be omitted when match_type is DefaultBranch."
  }

  validation {
    condition = length(distinct([
      for policy in var.branch_policy_status_check : coalesce(policy.key, "status_check")
    ])) == length(var.branch_policy_status_check)
    error_message = "branch_policy_status_check keys must be unique; set key when multiple policies are defined."
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
          scope.repository_id == null || length(trimspace(scope.repository_id)) > 0
        )
      ])
    ])
    error_message = "branch_policy_work_item_linking.scope.repository_id must be a non-empty string when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.branch_policy_work_item_linking : alltrue([
        for scope in policy.scope : scope.repository_id != null
      ])
    ])
    error_message = "branch_policy_work_item_linking.scope.repository_id is required when the module repository is not created."
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
    condition = alltrue([
      for policy in var.branch_policy_work_item_linking : alltrue([
        for scope in policy.scope : (
          scope.repository_ref == null || length(trimspace(scope.repository_ref)) > 0
        )
      ])
    ])
    error_message = "branch_policy_work_item_linking.scope.repository_ref must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.branch_policy_work_item_linking : alltrue([
        for scope in policy.scope : (
          coalesce(scope.match_type, "DefaultBranch") != "DefaultBranch" || scope.repository_ref == null
        )
      ])
    ])
    error_message = "branch_policy_work_item_linking.scope.repository_ref must be omitted when match_type is DefaultBranch."
  }

  validation {
    condition = length(distinct([
      for policy in var.branch_policy_work_item_linking : coalesce(policy.key, "work_item_linking")
    ])) == length(var.branch_policy_work_item_linking)
    error_message = "branch_policy_work_item_linking keys must be unique; set key when multiple policies are defined."
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
      for policy in var.repository_policy_author_email_pattern : alltrue([
        for pattern in policy.author_email_patterns : length(trimspace(pattern)) > 0
      ])
    ])
    error_message = "repository_policy_author_email_pattern.author_email_patterns must contain non-empty values."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_author_email_pattern : (
        policy.repository_ids == null || length(policy.repository_ids) > 0
      )
    ])
    error_message = "repository_policy_author_email_pattern.repository_ids must not be empty when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_author_email_pattern : alltrue([
        for repository_id in coalesce(policy.repository_ids, []) : length(trimspace(repository_id)) > 0
      ])
    ])
    error_message = "repository_policy_author_email_pattern.repository_ids must contain non-empty values when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.repository_policy_author_email_pattern : policy.repository_ids != null
    ])
    error_message = "repository_policy_author_email_pattern.repository_ids are required when the module repository is not created."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_author_email_pattern : coalesce(policy.key, "author_email_pattern")
    ])) == length(var.repository_policy_author_email_pattern)
    error_message = "repository_policy_author_email_pattern keys must be unique; set key when multiple policies are defined."
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
        policy.repository_ids == null || length(policy.repository_ids) > 0
      )
    ])
    error_message = "repository_policy_case_enforcement.repository_ids must not be empty when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_case_enforcement : alltrue([
        for repository_id in coalesce(policy.repository_ids, []) : length(trimspace(repository_id)) > 0
      ])
    ])
    error_message = "repository_policy_case_enforcement.repository_ids must contain non-empty values when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.repository_policy_case_enforcement : policy.repository_ids != null
    ])
    error_message = "repository_policy_case_enforcement.repository_ids are required when the module repository is not created."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_case_enforcement : coalesce(policy.key, "case_enforcement")
    ])) == length(var.repository_policy_case_enforcement)
    error_message = "repository_policy_case_enforcement keys must be unique; set key when multiple policies are defined."
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
      for policy in var.repository_policy_file_path_pattern : alltrue([
        for pattern in policy.filepath_patterns : length(trimspace(pattern)) > 0
      ])
    ])
    error_message = "repository_policy_file_path_pattern.filepath_patterns must contain non-empty values."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_file_path_pattern : (
        policy.repository_ids == null || length(policy.repository_ids) > 0
      )
    ])
    error_message = "repository_policy_file_path_pattern.repository_ids must not be empty when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_file_path_pattern : alltrue([
        for repository_id in coalesce(policy.repository_ids, []) : length(trimspace(repository_id)) > 0
      ])
    ])
    error_message = "repository_policy_file_path_pattern.repository_ids must contain non-empty values when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.repository_policy_file_path_pattern : policy.repository_ids != null
    ])
    error_message = "repository_policy_file_path_pattern.repository_ids are required when the module repository is not created."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_file_path_pattern : coalesce(policy.key, "file_path_pattern")
    ])) == length(var.repository_policy_file_path_pattern)
    error_message = "repository_policy_file_path_pattern keys must be unique; set key when multiple policies are defined."
  }
}

# -----------------------------------------------------------------------------
# Repository Policies - Max File Size
# -----------------------------------------------------------------------------

variable "repository_policy_max_file_size" {
  description = "List of max file size repository policies."
  type = list(object({
    key            = optional(string)
    enabled        = optional(bool)
    blocking       = optional(bool)
    max_file_size  = number
    repository_ids = optional(list(string))
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
        policy.repository_ids == null || length(policy.repository_ids) > 0
      )
    ])
    error_message = "repository_policy_max_file_size.repository_ids must not be empty when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_max_file_size : alltrue([
        for repository_id in coalesce(policy.repository_ids, []) : length(trimspace(repository_id)) > 0
      ])
    ])
    error_message = "repository_policy_max_file_size.repository_ids must contain non-empty values when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.repository_policy_max_file_size : policy.repository_ids != null
    ])
    error_message = "repository_policy_max_file_size.repository_ids are required when the module repository is not created."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_max_file_size : coalesce(policy.key, "max_file_size")
    ])) == length(var.repository_policy_max_file_size)
    error_message = "repository_policy_max_file_size keys must be unique; set key when multiple policies are defined."
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
        policy.repository_ids == null || length(policy.repository_ids) > 0
      )
    ])
    error_message = "repository_policy_max_path_length.repository_ids must not be empty when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_max_path_length : alltrue([
        for repository_id in coalesce(policy.repository_ids, []) : length(trimspace(repository_id)) > 0
      ])
    ])
    error_message = "repository_policy_max_path_length.repository_ids must contain non-empty values when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.repository_policy_max_path_length : policy.repository_ids != null
    ])
    error_message = "repository_policy_max_path_length.repository_ids are required when the module repository is not created."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_max_path_length : coalesce(policy.key, "max_path_length")
    ])) == length(var.repository_policy_max_path_length)
    error_message = "repository_policy_max_path_length keys must be unique; set key when multiple policies are defined."
  }
}

# -----------------------------------------------------------------------------
# Repository Policies - Reserved Names
# -----------------------------------------------------------------------------

variable "repository_policy_reserved_names" {
  description = "List of reserved names repository policies."
  type = list(object({
    key            = optional(string)
    enabled        = optional(bool)
    blocking       = optional(bool)
    repository_ids = optional(list(string))
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
        policy.repository_ids == null || length(policy.repository_ids) > 0
      )
    ])
    error_message = "repository_policy_reserved_names.repository_ids must not be empty when provided."
  }

  validation {
    condition = alltrue([
      for policy in var.repository_policy_reserved_names : alltrue([
        for repository_id in coalesce(policy.repository_ids, []) : length(trimspace(repository_id)) > 0
      ])
    ])
    error_message = "repository_policy_reserved_names.repository_ids must contain non-empty values when provided."
  }

  validation {
    condition = var.name != null || alltrue([
      for policy in var.repository_policy_reserved_names : policy.repository_ids != null
    ])
    error_message = "repository_policy_reserved_names.repository_ids are required when the module repository is not created."
  }

  validation {
    condition = length(distinct([
      for policy in var.repository_policy_reserved_names : coalesce(policy.key, "reserved_names")
    ])) == length(var.repository_policy_reserved_names)
    error_message = "repository_policy_reserved_names keys must be unique; set key when multiple policies are defined."
  }
}
