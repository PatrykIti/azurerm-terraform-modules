# -----------------------------------------------------------------------------
# Security Role Assignment (single)
# -----------------------------------------------------------------------------

variable "scope" {
  description = "Scope for the Azure DevOps security role assignment (for example, project)."
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
  description = "Role name to assign (e.g., Reader, Contributor)."
  type        = string

  validation {
    condition     = trimspace(var.role_name) != ""
    error_message = "role_name must be a non-empty string."
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
