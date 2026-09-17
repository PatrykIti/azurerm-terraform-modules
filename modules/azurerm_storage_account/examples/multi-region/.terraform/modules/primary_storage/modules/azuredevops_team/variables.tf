# -----------------------------------------------------------------------------
# Project
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "Azure DevOps project ID where the team will be created."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must be a non-empty string."
  }
}

# -----------------------------------------------------------------------------
# Team
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name of the Azure DevOps team."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must be a non-empty string."
  }
}

variable "description" {
  description = "Description of the Azure DevOps team."
  type        = string
  default     = null

  validation {
    condition     = var.description == null || length(trimspace(var.description)) > 0
    error_message = "description must be a non-empty string when provided."
  }
}

# -----------------------------------------------------------------------------
# Team Members
# -----------------------------------------------------------------------------

variable "team_members" {
  description = "List of team membership assignments."
  type = list(object({
    key                = optional(string)
    team_id            = optional(string)
    member_descriptors = list(string)
    mode               = optional(string, "add")
  }))
  default = []

  validation {
    condition = alltrue([
      for membership in var.team_members : (
        membership.team_id == null || length(trimspace(membership.team_id)) > 0
      )
    ])
    error_message = "team_members.team_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for membership in var.team_members : (
        membership.key == null || length(trimspace(membership.key)) > 0
      )
    ])
    error_message = "team_members.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for membership in var.team_members : (
        membership.team_id != null || membership.key != null
      )
    ])
    error_message = "team_members entries must set key when team_id is not provided."
  }

  validation {
    condition = alltrue([
      for membership in var.team_members : (
        length(membership.member_descriptors) > 0 &&
        alltrue([
          for descriptor in membership.member_descriptors : length(trimspace(descriptor)) > 0
        ])
      )
    ])
    error_message = "Each team_members entry must include at least one non-empty member descriptor."
  }

  validation {
    condition = alltrue([
      for membership in var.team_members : contains(["add", "overwrite"], coalesce(membership.mode, "add"))
    ])
    error_message = "team_members.mode must be one of: add, overwrite."
  }

  validation {
    condition = length(var.team_members) == length(distinct([
      for membership in var.team_members : try(coalesce(membership.key, membership.team_id), "")
    ]))
    error_message = "team_members entries must be unique by key or team_id."
  }
}

# -----------------------------------------------------------------------------
# Team Administrators
# -----------------------------------------------------------------------------

variable "team_administrators" {
  description = "List of team administrator assignments."
  type = list(object({
    key               = optional(string)
    team_id           = optional(string)
    admin_descriptors = list(string)
    mode              = optional(string, "add")
  }))
  default = []

  validation {
    condition = alltrue([
      for admin in var.team_administrators : (
        admin.team_id == null || length(trimspace(admin.team_id)) > 0
      )
    ])
    error_message = "team_administrators.team_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for admin in var.team_administrators : (
        admin.key == null || length(trimspace(admin.key)) > 0
      )
    ])
    error_message = "team_administrators.key must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for admin in var.team_administrators : (
        admin.team_id != null || admin.key != null
      )
    ])
    error_message = "team_administrators entries must set key when team_id is not provided."
  }

  validation {
    condition = alltrue([
      for admin in var.team_administrators : (
        length(admin.admin_descriptors) > 0 &&
        alltrue([
          for descriptor in admin.admin_descriptors : length(trimspace(descriptor)) > 0
        ])
      )
    ])
    error_message = "Each team_administrators entry must include at least one non-empty admin descriptor."
  }

  validation {
    condition = alltrue([
      for admin in var.team_administrators : contains(["add", "overwrite"], coalesce(admin.mode, "add"))
    ])
    error_message = "team_administrators.mode must be one of: add, overwrite."
  }

  validation {
    condition = length(var.team_administrators) == length(distinct([
      for admin in var.team_administrators : try(coalesce(admin.key, admin.team_id), "")
    ]))
    error_message = "team_administrators entries must be unique by key or team_id."
  }
}
