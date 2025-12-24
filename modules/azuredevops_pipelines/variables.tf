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
# Build Folders
# -----------------------------------------------------------------------------

variable "build_folders" {
  description = "List of build folders to manage."
  type = list(object({
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
}

# -----------------------------------------------------------------------------
# Build Definitions
# -----------------------------------------------------------------------------

variable "build_definitions" {
  description = "Map of build definitions to manage."
  type = map(object({
    name                   = optional(string)
    path                   = optional(string)
    agent_pool_name        = optional(string)
    agent_specification    = optional(string)
    queue_status           = optional(string)
    job_authorization_scope = optional(string)

    repository = object({
      repo_id               = string
      repo_type             = string
      branch_name           = optional(string)
      service_connection_id = optional(string)
      yml_path              = optional(string)
      github_enterprise_url = optional(string)
      url                   = optional(string)
      report_build_status   = optional(bool)
    })

    ci_trigger = optional(object({
      use_yaml = optional(bool)
      override = optional(object({
        branch_filter = object({
          include = list(string)
          exclude = optional(list(string), [])
        })
        batch                         = optional(bool)
        path_filter                   = optional(object({
          include = optional(list(string))
          exclude = optional(list(string))
        }))
        max_concurrent_builds_per_branch = optional(number)
        polling_interval              = optional(number)
      }))
    }))

    pull_request_trigger = optional(object({
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
    }))

    build_completion_trigger = optional(object({
      build_definition_id  = optional(string)
      build_definition_key = optional(string)
      branch_filter = object({
        include = list(string)
        exclude = optional(list(string), [])
      })
    }))

    schedules = optional(list(object({
      branch_filter = object({
        include = list(string)
        exclude = optional(list(string), [])
      })
      days_to_build              = list(string)
      schedule_only_with_changes = optional(bool)
      start_hours                = optional(number)
      start_minutes              = optional(number)
      time_zone                  = optional(string)
    })))

    variable_groups = optional(list(string))

    variables = optional(list(object({
      name           = string
      value          = optional(string)
      secret_value   = optional(string)
      is_secret      = optional(bool)
      allow_override = optional(bool)
    })))

    features = optional(object({
      skip_first_run = optional(bool)
    }))

    jobs = optional(list(object({
      name                           = string
      ref_name                       = string
      condition                      = string
      job_timeout_in_minutes         = optional(number)
      job_cancel_timeout_in_minutes  = optional(number)
      job_authorization_scope        = optional(string)
      allow_scripts_auth_access_option = optional(bool)
      dependencies = optional(list(object({
        scope = string
      })))
      target = object({
        type     = string
        demands  = optional(list(string))
        execution_options = object({
          type             = string
          multipliers      = optional(list(string))
          max_concurrency  = optional(number)
          continue_on_error = optional(bool)
        })
      })
    })))
  }))
  default = {}

  validation {
    condition = alltrue([
      for definition in values(var.build_definitions) : (
        definition.name == null || length(trimspace(definition.name)) > 0
      )
    ])
    error_message = "build_definitions.name must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for definition in values(var.build_definitions) : length(trimspace(definition.repository.repo_id)) > 0
    ])
    error_message = "build_definitions.repository.repo_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for definition in values(var.build_definitions) : contains([
        "GitHub",
        "TfsGit",
        "Bitbucket",
        "GitHubEnterprise",
        "Git"
      ], definition.repository.repo_type)
    ])
    error_message = "build_definitions.repository.repo_type must be GitHub, TfsGit, Bitbucket, GitHubEnterprise, or Git."
  }

  validation {
    condition = alltrue([
      for definition in values(var.build_definitions) : (
        definition.queue_status == null || contains(["enabled", "paused", "disabled"], lower(definition.queue_status))
      )
    ])
    error_message = "build_definitions.queue_status must be enabled, paused, or disabled when provided."
  }

  validation {
    condition = alltrue([
      for definition in values(var.build_definitions) : (
        definition.build_completion_trigger == null || (
          (definition.build_completion_trigger.build_definition_id != null) !=
          (definition.build_completion_trigger.build_definition_key != null)
        )
      )
    ])
    error_message = "build_completion_trigger must set exactly one of build_definition_id or build_definition_key."
  }
}

# -----------------------------------------------------------------------------
# Build Definition Permissions
# -----------------------------------------------------------------------------

variable "build_definition_permissions" {
  description = "List of build definition permissions to assign."
  type = list(object({
    build_definition_id  = optional(string)
    build_definition_key = optional(string)
    principal            = string
    permissions          = map(string)
    replace              = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for permission in var.build_definition_permissions : (
        (permission.build_definition_id != null) != (permission.build_definition_key != null)
      )
    ])
    error_message = "build_definition_permissions must set exactly one of build_definition_id or build_definition_key."
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
}

# -----------------------------------------------------------------------------
# Build Folder Permissions
# -----------------------------------------------------------------------------

variable "build_folder_permissions" {
  description = "List of build folder permissions to assign."
  type = list(object({
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
}

# -----------------------------------------------------------------------------
# Pipeline Authorizations
# -----------------------------------------------------------------------------

variable "pipeline_authorizations" {
  description = "List of pipeline authorizations to manage."
  type = list(object({
    resource_id         = string
    type                = string
    pipeline_id         = optional(string)
    pipeline_key        = optional(string)
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
      ], authorization.type)
    ])
    error_message = "pipeline_authorizations.type must be endpoint, queue, variablegroup, environment, or repository."
  }

  validation {
    condition = alltrue([
      for authorization in var.pipeline_authorizations : (
        authorization.pipeline_id == null || authorization.pipeline_key == null
      )
    ])
    error_message = "pipeline_authorizations cannot set both pipeline_id and pipeline_key."
  }
}

# -----------------------------------------------------------------------------
# Resource Authorizations (legacy)
# -----------------------------------------------------------------------------

variable "resource_authorizations" {
  description = "List of resource authorizations to manage."
  type = list(object({
    resource_id         = string
    authorized          = bool
    definition_id       = optional(string)
    build_definition_key = optional(string)
    type                = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for authorization in var.resource_authorizations : (
        authorization.definition_id == null || authorization.build_definition_key == null
      )
    ])
    error_message = "resource_authorizations cannot set both definition_id and build_definition_key."
  }

  validation {
    condition = alltrue([
      for authorization in var.resource_authorizations : (
        authorization.type == null || contains(["endpoint", "queue", "variablegroup"], authorization.type)
      )
    ])
    error_message = "resource_authorizations.type must be endpoint, queue, or variablegroup when provided."
  }
}
