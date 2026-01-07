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
  description = "Name of the repository to create or import."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string."
  }
}

variable "default_branch" {
  description = "Default branch ref for the repository (for example, refs/heads/main)."
  type        = string
  default     = "refs/heads/main"
  nullable    = false

  validation {
    condition     = length(trimspace(var.default_branch)) > 0
    error_message = "default_branch must be a non-empty string."
  }

  validation {
    condition     = startswith(var.default_branch, "refs/heads/")
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
  default   = {}
  sensitive = true

  validation {
    condition = var.initialization == null || (
      var.initialization.init_type != null &&
      contains(["Uninitialized", "Clean", "Import"], var.initialization.init_type)
    )
    error_message = "initialization.init_type must be Uninitialized, Clean, or Import."
  }

  validation {
    condition = var.initialization == null || (
      var.initialization.init_type == "Import"
      ? (
        var.initialization.source_type != null &&
        var.initialization.source_type == "Git"
      )
      : var.initialization.source_type == null
    )
    error_message = "initialization.source_type must be Git when init_type is Import, and null otherwise."
  }

  validation {
    condition = var.initialization == null || (
      var.initialization.init_type == "Import"
      ? (
        var.initialization.source_url != null &&
        length(trimspace(var.initialization.source_url)) > 0
      )
      : var.initialization.source_url == null
    )
    error_message = "initialization.source_url is required when init_type is Import and must be null otherwise."
  }

  validation {
    condition = var.initialization == null || (
      var.initialization.init_type == "Import"
      ? (
        (
          var.initialization.service_connection_id != null &&
          length(trimspace(var.initialization.service_connection_id)) > 0 &&
          var.initialization.username == null &&
          var.initialization.password == null
          ) || (
          var.initialization.service_connection_id == null &&
          var.initialization.username != null &&
          length(trimspace(var.initialization.username)) > 0 &&
          var.initialization.password != null &&
          length(trimspace(var.initialization.password)) > 0
        )
      )
      : (
        var.initialization.service_connection_id == null &&
        var.initialization.username == null &&
        var.initialization.password == null
      )
    )
    error_message = "initialization Import requires service_connection_id or username/password (exactly one), and auth fields are only allowed when init_type is Import."
  }
}

# -----------------------------------------------------------------------------
# Repository Policies
# -----------------------------------------------------------------------------

variable "policies" {
  description = "Repository policy configuration."
  type = object({
    author_email_pattern = optional(object({
      enabled               = optional(bool)
      blocking              = optional(bool)
      author_email_patterns = list(string)
    }), null)
    file_path_pattern = optional(object({
      enabled           = optional(bool)
      blocking          = optional(bool)
      filepath_patterns = list(string)
    }), null)
    case_enforcement = optional(object({
      enabled                 = optional(bool)
      blocking                = optional(bool)
      enforce_consistent_case = bool
    }), null)
    reserved_names = optional(object({
      enabled  = optional(bool)
      blocking = optional(bool)
    }), null)
    maximum_path_length = optional(object({
      enabled         = optional(bool)
      blocking        = optional(bool)
      max_path_length = number
    }), null)
    maximum_file_size = optional(object({
      enabled       = optional(bool)
      blocking      = optional(bool)
      max_file_size = number
    }), null)
  })
  default  = {}
  nullable = false

  validation {
    condition = var.policies.author_email_pattern == null || (
      length(var.policies.author_email_pattern.author_email_patterns) > 0 &&
      alltrue([
        for pattern in var.policies.author_email_pattern.author_email_patterns : length(trimspace(pattern)) > 0
      ])
    )
    error_message = "policies.author_email_pattern.author_email_patterns must contain non-empty values."
  }

  validation {
    condition = var.policies.file_path_pattern == null || (
      length(var.policies.file_path_pattern.filepath_patterns) > 0 &&
      alltrue([
        for pattern in var.policies.file_path_pattern.filepath_patterns : length(trimspace(pattern)) > 0
      ])
    )
    error_message = "policies.file_path_pattern.filepath_patterns must contain non-empty values."
  }

  validation {
    condition = var.policies.maximum_path_length == null || (
      var.policies.maximum_path_length.max_path_length > 0
    )
    error_message = "policies.maximum_path_length.max_path_length must be greater than 0."
  }

  validation {
    condition = var.policies.maximum_file_size == null || (
      var.policies.maximum_file_size.max_file_size > 0
    )
    error_message = "policies.maximum_file_size.max_file_size must be greater than 0."
  }
}

# -----------------------------------------------------------------------------
# Branches and Branch Policies
# -----------------------------------------------------------------------------

variable "branches" {
  description = "List of Git repository branches and their policy configuration."
  type = list(object({
    name          = string
    ref_branch    = optional(string)
    ref_tag       = optional(string)
    ref_commit_id = optional(string)
    policies = optional(object({
      min_reviewers = optional(object({
        enabled                                = optional(bool)
        blocking                               = optional(bool)
        reviewer_count                         = number
        submitter_can_vote                     = optional(bool)
        last_pusher_cannot_approve             = optional(bool)
        allow_completion_with_rejects_or_waits = optional(bool)
        on_push_reset_approved_votes           = optional(bool)
        on_push_reset_all_votes                = optional(bool)
        on_last_iteration_require_vote         = optional(bool)
      }), null)
      comment_resolution = optional(object({
        enabled  = optional(bool)
        blocking = optional(bool)
      }), null)
      work_item_linking = optional(object({
        enabled  = optional(bool)
        blocking = optional(bool)
      }), null)
      merge_types = optional(object({
        enabled                       = optional(bool)
        blocking                      = optional(bool)
        allow_squash                  = optional(bool)
        allow_rebase_and_fast_forward = optional(bool)
        allow_basic_no_fast_forward   = optional(bool)
        allow_rebase_with_merge       = optional(bool)
      }), null)
      build_validation = optional(list(object({
        name                        = string
        enabled                     = optional(bool)
        blocking                    = optional(bool)
        build_definition_id         = string
        display_name                = string
        manual_queue_only           = optional(bool)
        queue_on_source_update_only = optional(bool)
        valid_duration              = optional(number)
        filename_patterns           = optional(list(string))
      })), [])
      status_check = optional(list(object({
        name                 = string
        enabled              = optional(bool)
        blocking             = optional(bool)
        genre                = optional(string)
        author_id            = optional(string)
        invalidate_on_update = optional(bool)
        applicability        = optional(string)
        filename_patterns    = optional(list(string))
        display_name         = optional(string)
      })), [])
      auto_reviewers = optional(list(object({
        name                        = string
        enabled                     = optional(bool)
        blocking                    = optional(bool)
        auto_reviewer_ids           = list(string)
        path_filters                = optional(list(string))
        submitter_can_vote          = optional(bool)
        message                     = optional(string)
        minimum_number_of_reviewers = optional(number)
      })), [])
    }), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for branch in var.branches : length(trimspace(branch.name)) > 0
    ])
    error_message = "branches.name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : branch.policies != null
    ])
    error_message = "branches.policies must not be null; omit it or use {}."
  }

  validation {
    condition = length(distinct([
      for branch in var.branches : branch.name
    ])) == length(var.branches)
    error_message = "branches.name values must be unique."
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
        branch.ref_branch == null || startswith(branch.ref_branch, "refs/heads/")
      )
    ])
    error_message = "branches.ref_branch must start with refs/heads/ when provided."
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
        branch.ref_tag == null || startswith(branch.ref_tag, "refs/tags/")
      )
    ])
    error_message = "branches.ref_tag must start with refs/tags/ when provided."
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
        ])) == 1
      )
    ])
    error_message = "branches must set exactly one of ref_branch, ref_tag, or ref_commit_id."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : (
        branch.policies.min_reviewers == null ||
        branch.policies.min_reviewers.reviewer_count > 0
      )
    ])
    error_message = "branches.policies.min_reviewers.reviewer_count must be greater than 0."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for policy in branch.policies.build_validation : length(trimspace(policy.name)) > 0
      ])
    ])
    error_message = "branches.policies.build_validation.name must be a non-empty string."
  }

  validation {
    condition = (
      length(distinct(flatten([
        for branch in var.branches : [
          for policy in branch.policies.build_validation : policy.name
        ]
        ]))) == length(flatten([
        for branch in var.branches : [
          for policy in branch.policies.build_validation : policy.name
        ]
      ]))
    )
    error_message = "branches.policies.build_validation names must be unique across all branches."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for policy in branch.policies.build_validation :
        length(trimspace(policy.build_definition_id)) > 0
      ])
    ])
    error_message = "branches.policies.build_validation.build_definition_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for policy in branch.policies.build_validation :
        length(trimspace(policy.display_name)) > 0
      ])
    ])
    error_message = "branches.policies.build_validation.display_name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for policy in branch.policies.build_validation :
        policy.valid_duration == null || policy.valid_duration >= 0
      ])
    ])
    error_message = "branches.policies.build_validation.valid_duration must be 0 or greater when provided."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for policy in branch.policies.status_check : length(trimspace(policy.name)) > 0
      ])
    ])
    error_message = "branches.policies.status_check.name must be a non-empty string."
  }

  validation {
    condition = (
      length(distinct(flatten([
        for branch in var.branches : [
          for policy in branch.policies.status_check : policy.name
        ]
        ]))) == length(flatten([
        for branch in var.branches : [
          for policy in branch.policies.status_check : policy.name
        ]
      ]))
    )
    error_message = "branches.policies.status_check names must be unique across all branches."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for policy in branch.policies.status_check : (
          policy.genre == null || length(trimspace(policy.genre)) > 0
        )
      ])
    ])
    error_message = "branches.policies.status_check.genre must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for policy in branch.policies.status_check : (
          policy.display_name == null || length(trimspace(policy.display_name)) > 0
        )
      ])
    ])
    error_message = "branches.policies.status_check.display_name must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for policy in branch.policies.auto_reviewers : length(trimspace(policy.name)) > 0
      ])
    ])
    error_message = "branches.policies.auto_reviewers.name must be a non-empty string."
  }

  validation {
    condition = (
      length(distinct(flatten([
        for branch in var.branches : [
          for policy in branch.policies.auto_reviewers : policy.name
        ]
        ]))) == length(flatten([
        for branch in var.branches : [
          for policy in branch.policies.auto_reviewers : policy.name
        ]
      ]))
    )
    error_message = "branches.policies.auto_reviewers names must be unique across all branches."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for policy in branch.policies.auto_reviewers : length(policy.auto_reviewer_ids) > 0
      ])
    ])
    error_message = "branches.policies.auto_reviewers.auto_reviewer_ids must not be empty."
  }

  validation {
    condition = alltrue([
      for branch in var.branches : alltrue([
        for policy in branch.policies.auto_reviewers : alltrue([
          for reviewer_id in policy.auto_reviewer_ids : length(trimspace(reviewer_id)) > 0
        ])
      ])
    ])
    error_message = "branches.policies.auto_reviewers.auto_reviewer_ids must contain non-empty values."
  }
}

# -----------------------------------------------------------------------------
# Files
# -----------------------------------------------------------------------------

variable "files" {
  description = "List of Git repository files to manage."
  type = list(object({
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
      for file in var.files : format("%s:%s", file.file, coalesce(file.branch, "default"))
    ])) == length(var.files)
    error_message = "files entries must be unique by file path and branch."
  }
}

# -----------------------------------------------------------------------------
# Git Permissions
# -----------------------------------------------------------------------------

variable "git_permissions" {
  description = "List of Git permissions to assign."
  type = list(object({
    branch_name = optional(string)
    principal   = string
    permissions = map(string)
    replace     = optional(bool, true)
  }))
  default = []

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
      for perm in var.git_permissions : format(
        "%s:%s",
        coalesce(perm.branch_name, "root"),
        perm.principal
      )
    ])) == length(var.git_permissions)
    error_message = "git_permissions entries must be unique by branch_name and principal."
  }
}
