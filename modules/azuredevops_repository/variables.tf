# -----------------------------------------------------------------------------
# Core
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
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
    initialization = object({
      init_type             = string
      source_type           = optional(string)
      source_url            = optional(string)
      service_connection_id = optional(string)
      username              = optional(string)
      password              = optional(string)
    })
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
      for repo in values(var.repositories) : contains([
        "Uninitialized",
        "Clean",
        "Import",
      ], repo.initialization.init_type)
    ])
    error_message = "repositories.initialization.init_type must be Uninitialized, Clean, or Import."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repositories) : (
        repo.initialization.source_type == null || repo.initialization.source_type == "Git"
      )
    ])
    error_message = "repositories.initialization.source_type must be Git when provided."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repositories) : !(
        repo.initialization.service_connection_id != null &&
        (repo.initialization.username != null || repo.initialization.password != null)
      )
    ])
    error_message = "repositories.initialization.service_connection_id conflicts with username/password."
  }

  validation {
    condition = alltrue([
      for repo in values(var.repositories) : (
        (repo.initialization.username == null && repo.initialization.password == null) ||
        (repo.initialization.username != null && repo.initialization.password != null)
      )
    ])
    error_message = "repositories.initialization.username and password must be set together."
  }
}

# -----------------------------------------------------------------------------
# Branches
# -----------------------------------------------------------------------------

variable "branches" {
  description = "List of Git repository branches to manage."
  type = list(object({
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
        (branch.repository_id != null) != (branch.repository_key != null)
      )
    ])
    error_message = "branches must set exactly one of repository_id or repository_key."
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
}

# -----------------------------------------------------------------------------
# Files
# -----------------------------------------------------------------------------

variable "files" {
  description = "List of Git repository files to manage."
  type = list(object({
    repository_id     = optional(string)
    repository_key    = optional(string)
    file              = string
    content           = string
    branch            = optional(string)
    commit_message    = optional(string)
    overwrite_on_create = optional(bool)
    author_name       = optional(string)
    author_email      = optional(string)
    committer_name    = optional(string)
    committer_email   = optional(string)
  }))
  default = []

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
}

# -----------------------------------------------------------------------------
# Git Permissions
# -----------------------------------------------------------------------------

variable "git_permissions" {
  description = "List of Git permissions to assign."
  type = list(object({
    repository_id  = optional(string)
    repository_key = optional(string)
    branch_name    = optional(string)
    principal      = string
    permissions    = map(string)
    replace        = optional(bool)
  }))
  default = []

  validation {
    condition = alltrue([
      for perm in var.git_permissions : (
        perm.repository_id == null || perm.repository_key == null
      )
    ])
    error_message = "git_permissions cannot set both repository_id and repository_key."
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
        perm.branch_name == null || perm.repository_id != null || perm.repository_key != null
      )
    ])
    error_message = "git_permissions.branch_name requires repository_id or repository_key."
  }
}

# -----------------------------------------------------------------------------
# Branch Policies - Auto Reviewers
# -----------------------------------------------------------------------------

variable "branch_policy_auto_reviewers" {
  description = "List of auto reviewer branch policies."
  type = list(object({
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
      for policy in var.branch_policy_auto_reviewers : length(policy.auto_reviewer_ids) > 0
    ])
    error_message = "branch_policy_auto_reviewers.auto_reviewer_ids must not be empty."
  }
}

# -----------------------------------------------------------------------------
# Branch Policies - Build Validation
# -----------------------------------------------------------------------------

variable "branch_policy_build_validation" {
  description = "List of build validation branch policies."
  type = list(object({
    enabled                   = optional(bool)
    blocking                  = optional(bool)
    build_definition_id       = string
    display_name              = string
    manual_queue_only         = optional(bool)
    queue_on_source_update_only = optional(bool)
    valid_duration            = optional(number)
    filename_patterns         = optional(list(string))
    scope = list(object({
      repository_id  = optional(string)
      repository_key = optional(string)
      repository_ref = optional(string)
      match_type     = optional(string)
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Branch Policies - Comment Resolution
# -----------------------------------------------------------------------------

variable "branch_policy_comment_resolution" {
  description = "List of comment resolution branch policies."
  type = list(object({
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
}

# -----------------------------------------------------------------------------
# Branch Policies - Merge Types
# -----------------------------------------------------------------------------

variable "branch_policy_merge_types" {
  description = "List of merge types branch policies."
  type = list(object({
    enabled                      = optional(bool)
    blocking                     = optional(bool)
    allow_squash                 = optional(bool)
    allow_rebase_and_fast_forward = optional(bool)
    allow_basic_no_fast_forward  = optional(bool)
    allow_rebase_with_merge      = optional(bool)
    scope = list(object({
      repository_id  = optional(string)
      repository_key = optional(string)
      repository_ref = optional(string)
      match_type     = optional(string)
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Branch Policies - Minimum Reviewers
# -----------------------------------------------------------------------------

variable "branch_policy_min_reviewers" {
  description = "List of minimum reviewers branch policies."
  type = list(object({
    enabled                          = optional(bool)
    blocking                         = optional(bool)
    reviewer_count                   = number
    submitter_can_vote               = optional(bool)
    last_pusher_cannot_approve       = optional(bool)
    allow_completion_with_rejects_or_waits = optional(bool)
    on_push_reset_approved_votes     = optional(bool)
    on_push_reset_all_votes          = optional(bool)
    on_last_iteration_require_vote   = optional(bool)
    scope = list(object({
      repository_id  = optional(string)
      repository_key = optional(string)
      repository_ref = optional(string)
      match_type     = optional(string)
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Branch Policies - Status Check
# -----------------------------------------------------------------------------

variable "branch_policy_status_check" {
  description = "List of status check branch policies."
  type = list(object({
    enabled            = optional(bool)
    blocking           = optional(bool)
    name               = string
    genre              = optional(string)
    author_id          = optional(string)
    invalidate_on_update = optional(bool)
    applicability      = optional(string)
    filename_patterns  = optional(list(string))
    display_name       = optional(string)
    scope = list(object({
      repository_id  = optional(string)
      repository_key = optional(string)
      repository_ref = optional(string)
      match_type     = optional(string)
    }))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Branch Policies - Work Item Linking
# -----------------------------------------------------------------------------

variable "branch_policy_work_item_linking" {
  description = "List of work item linking branch policies."
  type = list(object({
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
}

# -----------------------------------------------------------------------------
# Repository Policies - Author Email Pattern
# -----------------------------------------------------------------------------

variable "repository_policy_author_email_pattern" {
  description = "List of author email pattern repository policies."
  type = list(object({
    enabled               = optional(bool)
    blocking              = optional(bool)
    author_email_patterns = list(string)
    repository_ids        = optional(list(string))
    repository_keys       = optional(list(string))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Repository Policies - Case Enforcement
# -----------------------------------------------------------------------------

variable "repository_policy_case_enforcement" {
  description = "List of case enforcement repository policies."
  type = list(object({
    enabled                 = optional(bool)
    blocking                = optional(bool)
    enforce_consistent_case = bool
    repository_ids          = optional(list(string))
    repository_keys         = optional(list(string))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Repository Policies - Check Credentials
# -----------------------------------------------------------------------------

variable "repository_policy_check_credentials" {
  description = "List of check credentials repository policies."
  type = list(object({
    enabled         = optional(bool)
    blocking        = optional(bool)
    repository_ids  = optional(list(string))
    repository_keys = optional(list(string))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Repository Policies - File Path Pattern
# -----------------------------------------------------------------------------

variable "repository_policy_file_path_pattern" {
  description = "List of file path pattern repository policies."
  type = list(object({
    enabled          = optional(bool)
    blocking         = optional(bool)
    filepath_patterns = list(string)
    repository_ids   = optional(list(string))
    repository_keys  = optional(list(string))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Repository Policies - Max File Size
# -----------------------------------------------------------------------------

variable "repository_policy_max_file_size" {
  description = "List of max file size repository policies."
  type = list(object({
    enabled         = optional(bool)
    blocking        = optional(bool)
    max_file_size   = number
    repository_ids  = optional(list(string))
    repository_keys = optional(list(string))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Repository Policies - Max Path Length
# -----------------------------------------------------------------------------

variable "repository_policy_max_path_length" {
  description = "List of max path length repository policies."
  type = list(object({
    enabled         = optional(bool)
    blocking        = optional(bool)
    max_path_length = number
    repository_ids  = optional(list(string))
    repository_keys = optional(list(string))
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Repository Policies - Reserved Names
# -----------------------------------------------------------------------------

variable "repository_policy_reserved_names" {
  description = "List of reserved names repository policies."
  type = list(object({
    enabled         = optional(bool)
    blocking        = optional(bool)
    repository_ids  = optional(list(string))
    repository_keys = optional(list(string))
  }))
  default = []
}
