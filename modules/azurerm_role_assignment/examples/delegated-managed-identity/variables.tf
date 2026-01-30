variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-role-assignment-delegated-mi"
}

variable "principal_identity_name" {
  description = "User-assigned managed identity name used as principal."
  type        = string
  default     = "uai-role-assignment-principal"
}

variable "delegated_identity_name" {
  description = "User-assigned managed identity name used for delegated assignment."
  type        = string
  default     = "uai-role-assignment-delegated"
}
