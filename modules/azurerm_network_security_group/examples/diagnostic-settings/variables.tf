variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "rg-nsg-diagnostic-settings-example"
}

variable "nsg_name" {
  description = "Network Security Group name."
  type        = string
  default     = "nsg-diagnostic-settings-example"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name."
  type        = string
  default     = "law-nsg-diagnostic-settings-example"
}

variable "storage_account_name" {
  description = "Storage account name for diagnostics (lowercase, 3-24 chars)."
  type        = string
  default     = "stnsgdiagsettingsex"
}

variable "eventhub_namespace_name" {
  description = "Event Hub namespace name."
  type        = string
  default     = "evhns-nsg-diag-example"
}

variable "eventhub_name" {
  description = "Event Hub name."
  type        = string
  default     = "evh-nsg-diag-example"
}
