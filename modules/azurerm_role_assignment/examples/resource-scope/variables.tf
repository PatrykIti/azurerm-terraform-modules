variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-role-assignment-resource"
}

variable "identity_name" {
  description = "User-assigned managed identity name."
  type        = string
  default     = "uai-role-assignment-resource"
}

variable "storage_account_name" {
  description = "Storage account name used for the resource scope."
  type        = string
  default     = "saraassignresource"
}
