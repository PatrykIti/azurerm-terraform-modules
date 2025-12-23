# -----------------------------------------------------------------------------
# Core Project Configuration
# -----------------------------------------------------------------------------

variable "project" {
  description = "Configuration for the Azure DevOps project."
  type = object({
    name               = string
    description        = optional(string)
    visibility         = optional(string, "private")
    version_control    = optional(string, "Git")
    work_item_template = optional(string, "Agile")
    features           = optional(map(string))
  })

  validation {
    condition     = trim(var.project.name) != ""
    error_message = "project.name must not be empty."
  }

  validation {
    condition     = contains(["private", "public"], lower(var.project.visibility))
    error_message = "project.visibility must be one of: private, public."
  }

  validation {
    condition     = contains(["Git", "Tfvc"], var.project.version_control)
    error_message = "project.version_control must be one of: Git, Tfvc."
  }

  validation {
    condition = var.project.features == null || alltrue([
      for status in values(var.project.features) : contains(["enabled", "disabled"], status)
    ])
    error_message = "project.features values must be one of: enabled, disabled."
  }

  validation {
    condition = var.project.features == null || alltrue([
      for key in keys(var.project.features) : contains([
        "boards",
        "repositories",
        "pipelines",
        "testplans",
        "artifacts"
      ], key)
    ])
    error_message = "project.features keys must be one of: boards, repositories, pipelines, testplans, artifacts."
  }
}

# -----------------------------------------------------------------------------
# Project Features (separate resource)
# -----------------------------------------------------------------------------

variable "project_features" {
  description = "Map of project features managed via azuredevops_project_features. Use either this or project.features, not both."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key in keys(var.project_features) : contains([
        "boards",
        "repositories",
        "pipelines",
        "testplans",
        "artifacts"
      ], key)
    ])
    error_message = "project_features keys must be one of: boards, repositories, pipelines, testplans, artifacts."
  }

  validation {
    condition = alltrue([
      for status in values(var.project_features) : contains(["enabled", "disabled"], status)
    ])
    error_message = "project_features values must be one of: enabled, disabled."
  }
}

# -----------------------------------------------------------------------------
# Pipeline Settings
# -----------------------------------------------------------------------------

variable "pipeline_settings" {
  description = "Pipeline settings for the project. When null, settings are not managed."
  type = object({
    enforce_job_scope                    = optional(bool)
    enforce_referenced_repo_scoped_token = optional(bool)
    enforce_settable_var                 = optional(bool)
    publish_pipeline_metadata            = optional(bool)
    status_badges_are_private            = optional(bool)
    enforce_job_scope_for_release        = optional(bool)
  })
  default = null
}

# -----------------------------------------------------------------------------
# Project Tags
# -----------------------------------------------------------------------------

variable "project_tags" {
  description = "List of tags to assign to the project."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Project Permissions
# -----------------------------------------------------------------------------

variable "project_permissions" {
  description = "List of project permission assignments (group principals only)."
  type = list(object({
    principal   = string
    permissions = map(string)
    replace     = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for permission in var.project_permissions : alltrue([
        for status in values(permission.permissions) : contains(["Allow", "Deny", "NotSet"], status)
      ])
    ])
    error_message = "project_permissions values must be one of: Allow, Deny, NotSet."
  }
}

# -----------------------------------------------------------------------------
# Dashboards
# -----------------------------------------------------------------------------

variable "dashboards" {
  description = "List of dashboards to create in the project."
  type = list(object({
    name             = string
    description      = optional(string)
    team_id          = optional(string)
    refresh_interval = optional(number, 0)
  }))
  default = []

  validation {
    condition = alltrue([
      for dashboard in var.dashboards : contains([0, 5], dashboard.refresh_interval)
    ])
    error_message = "dashboards.refresh_interval must be 0 or 5."
  }
}
