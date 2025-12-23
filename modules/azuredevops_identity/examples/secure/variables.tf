variable "group_name_prefix" {
  description = "Prefix for Azure DevOps group names."
  type        = string
  default     = "ado-identity-secure"
}

variable "user_principal_name" {
  description = "Optional user principal name for stakeholder entitlement."
  type        = string
  default     = ""
}

variable "aad_group_display_name" {
  description = "Optional Azure AD group display name for stakeholder entitlements."
  type        = string
  default     = ""
}
