variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-role-assignment-mg"
}

variable "identity_name" {
  description = "User-assigned managed identity name."
  type        = string
  default     = "uai-role-assignment-mg"
}

variable "management_group_id" {
  description = "Existing management group ID (for example: /providers/Microsoft.Management/managementGroups/<id>)."
  type        = string
}
