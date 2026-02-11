variable "location" {
  description = "Azure region for the resource group."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name for the secure example."
  type        = string
  default     = "rg-role-definition-secure"
}

variable "role_definition_name" {
  description = "Name of the custom role definition."
  type        = string
  default     = "custom-role-secure"
}
