# -----------------------------------------------------------------------------
# Security Role Assignments
# -----------------------------------------------------------------------------

variable "securityrole_assignments" {
  description = "List of security role assignments to manage."
  type = list(object({
    key         = optional(string)
    scope       = string
    resource_id = string
    role_name   = string
    identity_id = string
  }))
  default = []

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments :
      assignment.key == null || trimspace(assignment.key) != ""
    ])
    error_message = "securityrole_assignments.key must be a non-empty string when set."
  }

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments :
      trimspace(assignment.scope) != ""
    ])
    error_message = "securityrole_assignments.scope must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments :
      trimspace(assignment.resource_id) != ""
    ])
    error_message = "securityrole_assignments.resource_id must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments :
      trimspace(assignment.role_name) != ""
    ])
    error_message = "securityrole_assignments.role_name must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for assignment in var.securityrole_assignments :
      trimspace(assignment.identity_id) != ""
    ])
    error_message = "securityrole_assignments.identity_id must be a non-empty string."
  }

  validation {
    condition = length(distinct([
      for assignment in var.securityrole_assignments : coalesce(
        assignment.key,
        "${assignment.scope}/${assignment.resource_id}/${assignment.role_name}/${assignment.identity_id}"
      )
    ])) == length(var.securityrole_assignments)
    error_message = "securityrole_assignments keys must be unique (derived from key or scope/resource/role/identity)."
  }
}
