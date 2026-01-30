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
# Build Definition
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the build definition (pipeline)."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string."
  }
}

variable "path" {
  description = "Optional folder path for the build definition."
  type        = string
  default     = null

  validation {
    condition     = var.path == null || length(trimspace(var.path)) > 0
    error_message = "path must be a non-empty string when provided."
  }
}

variable "agent_pool_name" {
  description = "Agent pool name for the build definition."
  type        = string
  default     = null

  validation {
    condition     = var.agent_pool_name == null || length(trimspace(var.agent_pool_name)) > 0
    error_message = "agent_pool_name must be a non-empty string when provided."
  }
}

variable "agent_specification" {
  description = "Agent specification for the build definition."
  type        = string
  default     = null

  validation {
    condition     = var.agent_specification == null || length(trimspace(var.agent_specification)) > 0
    error_message = "agent_specification must be a non-empty string when provided."
  }
}

variable "queue_status" {
  description = "Queue status for the build definition (enabled, paused, disabled)."
  type        = string
  default     = null

  validation {
    condition = (
      var.queue_status == null ||
      contains(["enabled", "paused", "disabled"], lower(var.queue_status))
    )
    error_message = "queue_status must be enabled, paused, or disabled when provided."
  }
}

variable "job_authorization_scope" {
  description = "Job authorization scope for the build definition."
  type        = string
  default     = null

  validation {
    condition     = var.job_authorization_scope == null || length(trimspace(var.job_authorization_scope)) > 0
    error_message = "job_authorization_scope must be a non-empty string when provided."
  }
}

variable "repository" {
  description = "Repository settings for the build definition."
  type = object({
    repo_id               = string
    repo_type             = string
    branch_name           = optional(string)
    service_connection_id = optional(string)
    yml_path              = optional(string)
    github_enterprise_url = optional(string)
    url                   = optional(string)
    report_build_status   = optional(bool)
  })

  validation {
    condition     = length(trimspace(var.repository.repo_id)) > 0
    error_message = "repository.repo_id must be a non-empty string."
  }

  validation {
    condition = contains([
      "GitHub",
      "TfsGit",
      "Bitbucket",
      "GitHubEnterprise",
      "Git"
    ], var.repository.repo_type)
    error_message = "repository.repo_type must be GitHub, TfsGit, Bitbucket, GitHubEnterprise, or Git."
  }

  validation {
    condition = (
      var.repository.branch_name == null || length(trimspace(var.repository.branch_name)) > 0
    )
    error_message = "repository.branch_name must be a non-empty string when provided."
  }

  validation {
    condition = (
      var.repository.service_connection_id == null ||
      length(trimspace(var.repository.service_connection_id)) > 0
    )
    error_message = "repository.service_connection_id must be a non-empty string when provided."
  }

  validation {
    condition = (
      var.repository.yml_path == null || length(trimspace(var.repository.yml_path)) > 0
    )
    error_message = "repository.yml_path must be a non-empty string when provided."
  }

  validation {
    condition = (
      var.repository.github_enterprise_url == null ||
      length(trimspace(var.repository.github_enterprise_url)) > 0
    )
    error_message = "repository.github_enterprise_url must be a non-empty string when provided."
  }

  validation {
    condition = (
      var.repository.url == null || length(trimspace(var.repository.url)) > 0
    )
    error_message = "repository.url must be a non-empty string when provided."
  }
}

variable "ci_trigger" {
  description = "CI trigger configuration for the build definition."
  type = object({
    use_yaml = optional(bool)
    override = optional(object({
      branch_filter = object({
        include = list(string)
        exclude = optional(list(string), [])
      })
      batch = optional(bool)
      path_filter = optional(object({
        include = optional(list(string))
        exclude = optional(list(string))
      }))
      max_concurrent_builds_per_branch = optional(number)
      polling_interval                 = optional(number)
    }))
  })
  default = null
}

variable "pull_request_trigger" {
  description = "Pull request trigger configuration for the build definition."
  type = object({
    use_yaml       = optional(bool)
    initial_branch = optional(string)
    forks = optional(object({
      enabled       = bool
      share_secrets = bool
    }))
    override = optional(object({
      branch_filter = object({
        include = list(string)
        exclude = optional(list(string), [])
      })
      auto_cancel = optional(bool)
      path_filter = optional(object({
        include = optional(list(string))
        exclude = optional(list(string))
      }))
    }))
  })
  default = null
}

variable "build_completion_trigger" {
  description = "Build completion trigger configuration."
  type = object({
    build_definition_id = string
    branch_filter = object({
      include = list(string)
      exclude = optional(list(string), [])
    })
  })
  default = null

  validation {
    condition = (
      var.build_completion_trigger == null ||
      length(trimspace(var.build_completion_trigger.build_definition_id)) > 0
    )
    error_message = "build_completion_trigger.build_definition_id must be a non-empty string when provided."
  }

  validation {
    condition = (
      var.build_completion_trigger == null ||
      can(tonumber(var.build_completion_trigger.build_definition_id))
    )
    error_message = "build_completion_trigger.build_definition_id must be a numeric string when provided."
  }
}

variable "schedules" {
  description = "List of scheduled triggers for the build definition."
  type = list(object({
    branch_filter = object({
      include = list(string)
      exclude = optional(list(string), [])
    })
    days_to_build              = list(string)
    schedule_only_with_changes = optional(bool)
    start_hours                = optional(number)
    start_minutes              = optional(number)
    time_zone                  = optional(string)
  }))
  default = []
}

variable "variable_groups" {
  description = "Variable group IDs to link to the build definition."
  type        = list(string)
  default     = null
}

variable "variables" {
  description = "Variables to set for the build definition."
  type = list(object({
    name           = string
    value          = optional(string)
    secret_value   = optional(string)
    is_secret      = optional(bool)
    allow_override = optional(bool)
  }))
  default = []

  validation {
    condition = alltrue([
      for variable in var.variables : length(trimspace(variable.name)) > 0
    ])
    error_message = "variables.name must be a non-empty string."
  }
}

variable "features" {
  description = "Feature flags for the build definition."
  type = object({
    skip_first_run = optional(bool)
  })
  default = null
}

variable "jobs" {
  description = "Job definitions for the build definition."
  type = list(object({
    name                             = string
    ref_name                         = string
    condition                        = string
    job_timeout_in_minutes           = optional(number)
    job_cancel_timeout_in_minutes    = optional(number)
    job_authorization_scope          = optional(string)
    allow_scripts_auth_access_option = optional(bool)
    dependencies = optional(list(object({
      scope = string
    })))
    target = object({
      type    = string
      demands = optional(list(string))
      execution_options = object({
        type              = string
        multipliers       = optional(list(string))
        max_concurrency   = optional(number)
        continue_on_error = optional(bool)
      })
    })
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Build Folders
# -----------------------------------------------------------------------------

variable "build_folders" {
  description = "List of build folders to manage."
  type = list(object({
    key         = optional(string)
    path        = string
    description = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for folder in var.build_folders : length(trimspace(folder.path)) > 0
    ])
    error_message = "build_folders.path must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for folder in var.build_folders : (
        folder.key == null || length(trimspace(folder.key)) > 0
      )
    ])
    error_message = "build_folders.key must be a non-empty string when provided."
  }

  validation {
    condition     = length(var.build_folders) == length(distinct([for folder in var.build_folders : coalesce(folder.key, folder.path)]))
    error_message = "build_folders key or path values must be unique."
  }
}

# -----------------------------------------------------------------------------
# Build Definition Permissions
# -----------------------------------------------------------------------------

variable "build_definition_permissions" {
  description = "List of build definition permissions to assign."
  type = list(object({
    key                 = optional(string)
    build_definition_id = optional(string)
    principal           = string
    permissions         = map(string)
    replace             = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for permission in var.build_definition_permissions : (
        permission.build_definition_id == null || length(trimspace(permission.build_definition_id)) > 0
      )
    ])
    error_message = "build_definition_permissions.build_definition_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for permission in var.build_definition_permissions : (
        permission.key == null || length(trimspace(permission.key)) > 0
      )
    ])
    error_message = "build_definition_permissions.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for permission in var.build_definition_permissions : length(trimspace(permission.principal)) > 0
    ])
    error_message = "build_definition_permissions.principal must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for permission in var.build_definition_permissions : alltrue([
        for status in values(permission.permissions) : contains(["Allow", "Deny", "NotSet"], status)
      ])
    ])
    error_message = "build_definition_permissions values must be Allow, Deny, or NotSet."
  }

  validation {
    condition     = length(var.build_definition_permissions) == length(distinct([for permission in var.build_definition_permissions : coalesce(permission.key, permission.principal)]))
    error_message = "build_definition_permissions keys must be unique; set key when principals would collide."
  }
}

# -----------------------------------------------------------------------------
# Build Folder Permissions
# -----------------------------------------------------------------------------

variable "build_folder_permissions" {
  description = "List of build folder permissions to assign."
  type = list(object({
    key         = optional(string)
    path        = string
    principal   = string
    permissions = map(string)
    replace     = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for permission in var.build_folder_permissions : length(trimspace(permission.path)) > 0
    ])
    error_message = "build_folder_permissions.path must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for permission in var.build_folder_permissions : (
        permission.key == null || length(trimspace(permission.key)) > 0
      )
    ])
    error_message = "build_folder_permissions.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for permission in var.build_folder_permissions : length(trimspace(permission.principal)) > 0
    ])
    error_message = "build_folder_permissions.principal must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for permission in var.build_folder_permissions : alltrue([
        for status in values(permission.permissions) : contains(["Allow", "Deny", "NotSet"], status)
      ])
    ])
    error_message = "build_folder_permissions values must be Allow, Deny, or NotSet."
  }

  validation {
    condition = length(var.build_folder_permissions) == length(distinct([
      for permission in var.build_folder_permissions : coalesce(
        permission.key,
        format("%s:%s", permission.path, permission.principal)
      )
    ]))
    error_message = "build_folder_permissions keys must be unique; set key when path/principal pairs would collide."
  }
}

# -----------------------------------------------------------------------------
# Pipeline Authorizations
# -----------------------------------------------------------------------------

variable "pipeline_authorizations" {
  description = "List of pipeline authorizations to manage. Set key when resource_id is computed to keep for_each stable."
  type = list(object({
    key                 = optional(string)
    resource_id         = string
    type                = string
    pipeline_id         = optional(string)
    pipeline_project_id = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for authorization in var.pipeline_authorizations : contains([
        "endpoint",
        "queue",
        "variablegroup",
        "environment",
        "repository"
      ], lower(authorization.type))
    ])
    error_message = "pipeline_authorizations.type must be endpoint, queue, variablegroup, environment, or repository."
  }

  validation {
    condition = alltrue([
      for authorization in var.pipeline_authorizations : (
        authorization.pipeline_id == null || length(trimspace(authorization.pipeline_id)) > 0
      )
    ])
    error_message = "pipeline_authorizations.pipeline_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for authorization in var.pipeline_authorizations : (
        authorization.pipeline_id == null || can(tonumber(authorization.pipeline_id))
      )
    ])
    error_message = "pipeline_authorizations.pipeline_id must be a numeric string when provided."
  }

  validation {
    condition = alltrue([
      for authorization in var.pipeline_authorizations : (
        authorization.pipeline_project_id == null || length(trimspace(authorization.pipeline_project_id)) > 0
      )
    ])
    error_message = "pipeline_authorizations.pipeline_project_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for authorization in var.pipeline_authorizations : length(trimspace(authorization.resource_id)) > 0
    ])
    error_message = "pipeline_authorizations.resource_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for authorization in var.pipeline_authorizations : (
        authorization.key == null || length(trimspace(authorization.key)) > 0
      )
    ])
    error_message = "pipeline_authorizations.key must be a non-empty string when provided."
  }

  validation {
    condition = length(var.pipeline_authorizations) == length(distinct([
      for authorization in var.pipeline_authorizations : coalesce(
        authorization.key,
        format("%s:%s", lower(authorization.type), authorization.resource_id)
      )
    ]))
    error_message = "pipeline_authorizations keys must be unique; set key when type/resource pairs would collide."
  }
}

# -----------------------------------------------------------------------------
# Resource Authorizations (legacy)
# -----------------------------------------------------------------------------

variable "resource_authorizations" {
  description = "Legacy list of resource authorizations to manage. Prefer pipeline_authorizations; set key when resource_id is computed to keep for_each stable."
  type = list(object({
    key           = optional(string)
    resource_id   = string
    authorized    = bool
    definition_id = optional(string)
    type          = string
  }))
  default = []

  validation {
    condition = alltrue([
      for authorization in var.resource_authorizations : (
        authorization.definition_id == null || length(trimspace(authorization.definition_id)) > 0
      )
    ])
    error_message = "resource_authorizations.definition_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for authorization in var.resource_authorizations : (
        authorization.definition_id == null || can(tonumber(authorization.definition_id))
      )
    ])
    error_message = "resource_authorizations.definition_id must be a numeric string when provided."
  }

  validation {
    condition = alltrue([
      for authorization in var.resource_authorizations : length(trimspace(authorization.resource_id)) > 0
    ])
    error_message = "resource_authorizations.resource_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for authorization in var.resource_authorizations : (
        authorization.key == null || length(trimspace(authorization.key)) > 0
      )
    ])
    error_message = "resource_authorizations.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for authorization in var.resource_authorizations : (
        contains(["endpoint", "queue", "variablegroup"], lower(authorization.type))
      )
    ])
    error_message = "resource_authorizations.type must be endpoint, queue, or variablegroup."
  }

  validation {
    condition = alltrue([
      for authorization in var.resource_authorizations : authorization.authorized
    ])
    error_message = "resource_authorizations.authorized must be true; remove entries to revoke access."
  }

  validation {
    condition = length(var.resource_authorizations) == length(distinct([
      for authorization in var.resource_authorizations : coalesce(
        authorization.key,
        format("%s:%s", lower(authorization.type), authorization.resource_id)
      )
    ]))
    error_message = "resource_authorizations keys must be unique; set key when type/resource pairs would collide."
  }
}
