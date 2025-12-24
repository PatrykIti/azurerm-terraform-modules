# -----------------------------------------------------------------------------
# Project
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Azure DevOps project ID where teams will be created."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# Teams
# -----------------------------------------------------------------------------

variable "teams" {
  description = "Map of Azure DevOps teams to manage."
  type = map(object({
    name        = optional(string)
    description = optional(string)
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# Team Members
# -----------------------------------------------------------------------------

variable "team_members" {
  description = "List of team membership assignments."
  type = list(object({
    team_id            = optional(string)
    team_key           = optional(string)
    member_descriptors = list(string)
    mode               = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for membership in var.team_members : (
        (membership.team_id != null) != (membership.team_key != null)
      )
    ])
    error_message = "Each team_members entry must set exactly one of team_id or team_key."
  }

  validation {
    condition = alltrue([
      for membership in var.team_members : (
        membership.mode == null || contains(["add", "overwrite"], membership.mode)
      )
    ])
    error_message = "team_members.mode must be one of: add, overwrite."
  }

  validation {
    condition = alltrue([
      for membership in var.team_members : length(membership.member_descriptors) > 0
    ])
    error_message = "Each team_members entry must include at least one member descriptor."
  }
}

# -----------------------------------------------------------------------------
# Team Administrators
# -----------------------------------------------------------------------------

variable "team_administrators" {
  description = "List of team administrator assignments."
  type = list(object({
    team_id           = optional(string)
    team_key          = optional(string)
    admin_descriptors = list(string)
    mode              = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for admin in var.team_administrators : (
        (admin.team_id != null) != (admin.team_key != null)
      )
    ])
    error_message = "Each team_administrators entry must set exactly one of team_id or team_key."
  }

  validation {
    condition = alltrue([
      for admin in var.team_administrators : (
        admin.mode == null || contains(["add", "overwrite"], admin.mode)
      )
    ])
    error_message = "team_administrators.mode must be one of: add, overwrite."
  }

  validation {
    condition = alltrue([
      for admin in var.team_administrators : length(admin.admin_descriptors) > 0
    ])
    error_message = "Each team_administrators entry must include at least one admin descriptor."
  }
}
