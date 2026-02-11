variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the secure example."
  type        = string
  default     = "rg-role-assignment-secure"
}

variable "identity_name" {
  description = "User-assigned managed identity name."
  type        = string
  default     = "uai-role-assignment-secure"
}

variable "role_definition_name" {
  description = "Custom role definition name for secure example."
  type        = string
  default     = "custom-role-assignment-secure"
}
