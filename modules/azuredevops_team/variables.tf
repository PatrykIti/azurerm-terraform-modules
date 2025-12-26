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

  validation {
    condition = alltrue([
      for team_key, team in var.teams : (
        length(trimspace(team_key)) > 0 &&
        (team.name == null || length(trimspace(team.name)) > 0)
      )
    ])
    error_message = "teams map keys and team.name must be non-empty strings when provided."
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
    team_key           = optional(string)
    member_descriptors = list(string)
    mode               = optional(string, "add")
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
        membership.team_id == null || length(trimspace(membership.team_id)) > 0
      )
    ])
    error_message = "team_members.team_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for membership in var.team_members : (
        membership.team_key == null || length(trimspace(membership.team_key)) > 0
      )
    ])
    error_message = "team_members.team_key must be a non-empty string when provided."
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
        membership.team_key == null || contains(keys(var.teams), membership.team_key)
      )
    ])
    error_message = "team_members.team_key must reference a key defined in teams."
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
      for membership in var.team_members : try(coalesce(membership.key, membership.team_id, membership.team_key), "")
    ]))
    error_message = "team_members entries must be unique by key, team_id, or team_key."
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
    team_key          = optional(string)
    admin_descriptors = list(string)
    mode              = optional(string, "add")
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
        admin.team_id == null || length(trimspace(admin.team_id)) > 0
      )
    ])
    error_message = "team_administrators.team_id must be a non-empty string when provided."
  }

  validation {
    condition = alltrue([
      for admin in var.team_administrators : (
        admin.team_key == null || length(trimspace(admin.team_key)) > 0
      )
    ])
    error_message = "team_administrators.team_key must be a non-empty string when provided."
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
        admin.team_key == null || contains(keys(var.teams), admin.team_key)
      )
    ])
    error_message = "team_administrators.team_key must reference a key defined in teams."
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
      for admin in var.team_administrators : try(coalesce(admin.key, admin.team_id, admin.team_key), "")
    ]))
    error_message = "team_administrators entries must be unique by key, team_id, or team_key."
  }
}
