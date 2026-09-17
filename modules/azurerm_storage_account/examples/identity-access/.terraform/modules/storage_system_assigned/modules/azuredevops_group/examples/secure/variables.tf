variable "group_name_prefix" {
  description = "Prefix for Azure DevOps group names."
  type        = string
  default     = "ado-group-secure"
}

variable "aad_group_display_name" {
  description = "Optional Azure AD group display name for stakeholder entitlements."
  type        = string
  default     = ""
}
