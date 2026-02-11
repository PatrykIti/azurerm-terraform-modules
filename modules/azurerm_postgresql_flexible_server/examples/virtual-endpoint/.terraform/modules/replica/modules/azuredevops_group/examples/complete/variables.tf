variable "group_name_prefix" {
  description = "Prefix for Azure DevOps group names."
  type        = string
  default     = "ado-group-complete"
}

variable "aad_group_display_name" {
  description = "Optional Azure AD group display name for group entitlements."
  type        = string
  default     = ""
}
