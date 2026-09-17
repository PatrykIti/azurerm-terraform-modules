# -----------------------------------------------------------------------------
# Security Role Assignment (single)
# -----------------------------------------------------------------------------

variable "scope" {
  description = "Security role scope ID (for project scope, use the project GUID)."
  type        = string

  validation {
    condition     = trimspace(var.scope) != ""
    error_message = "scope must be a non-empty string."
  }
}

variable "resource_id" {
  description = "Target resource ID for the security role assignment (e.g., project ID)."
  type        = string

  validation {
    condition     = trimspace(var.resource_id) != ""
    error_message = "resource_id must be a non-empty string."
  }
}

variable "role_name" {
  description = "Role name to assign. Allowed values: Administrator, Reader, User; for scope distributedtask.library, Creator is also allowed."
  type        = string

  validation {
    condition     = trimspace(var.role_name) != ""
    error_message = "role_name must be a non-empty string."
  }

  validation {
    condition     = contains(["Administrator", "Reader", "User", "Creator"], var.role_name) && (var.role_name != "Creator" || var.scope == "distributedtask.library")
    error_message = "role_name must be Administrator, Reader, or User; Creator is only allowed when scope is distributedtask.library."
  }
}

variable "identity_id" {
  description = "Identity descriptor/ID to assign the role to."
  type        = string

  validation {
    condition     = trimspace(var.identity_id) != ""
    error_message = "identity_id must be a non-empty string."
  }
}
