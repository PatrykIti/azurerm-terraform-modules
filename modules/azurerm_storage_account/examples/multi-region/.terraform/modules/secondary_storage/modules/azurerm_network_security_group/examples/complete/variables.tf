variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "rg-nsg-complete-example"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name."
  type        = string
  default     = "law-nsg-complete-example"
}

variable "storage_account_name" {
  description = "Storage account name for diagnostic settings (lowercase, 3-24 chars)."
  type        = string
  default     = "stnsgcompleteexample"
}

variable "eventhub_namespace_name" {
  description = "Event Hub namespace name."
  type        = string
  default     = "evhns-nsg-complete-example"
}

variable "eventhub_name" {
  description = "Event Hub name."
  type        = string
  default     = "evh-nsg-complete-example"
}
