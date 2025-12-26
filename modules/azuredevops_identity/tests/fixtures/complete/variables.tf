variable "group_name_prefix" {
  description = "Prefix for Azure DevOps group names."
  type        = string
  default     = "ado-identity-complete-fixture"
}

variable "user_principal_name" {
  description = "Optional user principal name to test user entitlements."
  type        = string
  default     = ""
}
