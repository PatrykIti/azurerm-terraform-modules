variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-role-assignment-complete"
}

variable "identity_name" {
  description = "User-assigned managed identity name."
  type        = string
  default     = "uai-role-assignment-complete"
}

variable "storage_account_name" {
  description = "Storage account name for the ABAC condition example."
  type        = string
  default     = "saraassigncomplete"
}

variable "role_assignment_name" {
  description = "Role assignment name (GUID)."
  type        = string
  default     = "00000000-0000-0000-0000-000000000222"
}
