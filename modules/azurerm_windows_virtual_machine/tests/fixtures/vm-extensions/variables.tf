variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "random_suffix" {
  description = "Unique suffix appended to test resource names."
  type        = string
}

variable "resource_group_name" {
  description = "Optional resource group name override."
  type        = string
  default     = null
}
