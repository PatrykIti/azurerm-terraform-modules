variable "group_name_prefix" {
  description = "Prefix for Azure DevOps group names."
  type        = string
  default     = "ado-identity-complete"
}

variable "user_principal_name" {
  description = "Optional user principal name for entitlement assignment."
  type        = string
  default     = ""
}

variable "aad_group_display_name" {
  description = "Optional Azure AD group display name for group entitlements."
  type        = string
  default     = ""
}

variable "service_principal_origin_id" {
  description = "Optional Azure AD service principal object ID for entitlement."
  type        = string
  default     = ""
}

variable "security_role_assignment_resource_id" {
  description = "Optional resource ID for a sample security role assignment."
  type        = string
  default     = ""
}

variable "security_role_assignment_scope" {
  description = "Scope for the optional security role assignment."
  type        = string
  default     = "project"
}

variable "security_role_assignment_role_name" {
  description = "Role name for the optional security role assignment."
  type        = string
  default     = "Reader"
}
