# -----------------------------------------------------------------------------
# Core Project Configuration
# -----------------------------------------------------------------------------

variable "name" {
  description = "The name of the Azure DevOps project."
  type        = string

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name must not be empty."
  }
}

variable "description" {
  description = "The description of the Azure DevOps project."
  type        = string
  default     = null
}

variable "visibility" {
  description = "Specifies the project visibility. Possible values are: private, public."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "public"], lower(var.visibility))
    error_message = "visibility must be one of: private, public."
  }
}

variable "version_control" {
  description = "Specifies the version control system. Possible values are: Git, Tfvc."
  type        = string
  default     = "Git"

  validation {
    condition     = contains(["Git", "Tfvc"], var.version_control)
    error_message = "version_control must be one of: Git, Tfvc."
  }
}

variable "work_item_template" {
  description = "Specifies the work item template. Defaults to Agile."
  type        = string
  default     = "Agile"
}

variable "features" {
  description = "Project feature flags for azuredevops_project.features. Set to null to leave unmanaged."
  type        = map(string)
  default     = null

  validation {
    condition = var.features == null || alltrue([
      for status in values(var.features) : contains(["enabled", "disabled"], status)
    ])
    error_message = "features values must be one of: enabled, disabled."
  }

  validation {
    condition = var.features == null || alltrue([
      for key in keys(var.features) : contains([
        "boards",
        "repositories",
        "pipelines",
        "testplans",
        "artifacts"
      ], key)
    ])
    error_message = "features keys must be one of: boards, repositories, pipelines, testplans, artifacts."
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
      for dashboard in var.dashboards : trimspace(dashboard.name) != ""
    ])
    error_message = "dashboards.name must be a non-empty string."
  }

  validation {
    condition     = length(var.dashboards) == length(distinct([for dashboard in var.dashboards : dashboard.name]))
    error_message = "dashboards.name values must be unique."
  }

  validation {
    condition = alltrue([
      for dashboard in var.dashboards : contains([0, 5], dashboard.refresh_interval)
    ])
    error_message = "dashboards.refresh_interval must be 0 or 5."
  }
}
