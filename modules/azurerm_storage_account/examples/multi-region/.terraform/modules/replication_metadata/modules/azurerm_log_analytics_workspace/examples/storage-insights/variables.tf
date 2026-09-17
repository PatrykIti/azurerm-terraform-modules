variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-law-storage-insights-example"
}

variable "workspace_name" {
  description = "Log Analytics Workspace name."
  type        = string
  default     = "law-storage-insights-example"
}

variable "storage_account_name" {
  description = "Storage account name for storage insights."
  type        = string
  default     = "stlawstorageins"
}
