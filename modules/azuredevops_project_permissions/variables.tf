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
# Permissions
# -----------------------------------------------------------------------------

variable "permissions" {
  description = "List of project permission assignments."
  type = list(object({
    key         = optional(string)
    principal   = optional(string)
    group_name  = optional(string)
    scope       = optional(string)
    permissions = map(string)
    replace     = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for permission in var.permissions : (
        (permission.key == null || trimspace(permission.key) != "") &&
        (permission.principal == null || trimspace(permission.principal) != "") &&
        (permission.group_name == null || trimspace(permission.group_name) != "")
      )
    ])
    error_message = "permissions.key, permissions.principal, and permissions.group_name must be non-empty strings when provided."
  }

  validation {
    condition = alltrue([
      for permission in var.permissions : (
        (permission.principal != null && permission.group_name == null && permission.scope == null) ||
        (permission.principal == null && permission.group_name != null && permission.scope != null)
      )
    ])
    error_message = "Each permissions entry must set either principal or group_name+scope (but not both)."
  }

  validation {
    condition = alltrue([
      for permission in var.permissions : (
        permission.group_name == null ||
        (permission.scope != null && contains(["project", "collection"], permission.scope))
      )
    ])
    error_message = "permissions.scope must be one of: project, collection (when group_name is set)."
  }

  validation {
    condition = alltrue([
      for permission in var.permissions : alltrue([
        for status in values(permission.permissions) : contains(["Allow", "Deny", "NotSet"], status)
      ])
    ])
    error_message = "permissions.permissions values must be one of: Allow, Deny, NotSet."
  }

  validation {
    condition = length([
      for permission in var.permissions :
      coalesce(permission.key, permission.group_name, permission.principal)
      if permission.key != null || permission.group_name != null || permission.principal != null
      ]) == length(distinct([
        for permission in var.permissions :
        coalesce(permission.key, permission.group_name, permission.principal)
        if permission.key != null || permission.group_name != null || permission.principal != null
    ]))
    error_message = "permissions entries must have unique keys (key/group_name/principal)."
  }
}
