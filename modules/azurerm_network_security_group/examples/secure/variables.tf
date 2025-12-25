variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "rg-nsg-secure-example"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name."
  type        = string
  default     = "law-nsg-secure-example"
}

variable "storage_account_name" {
  description = "Storage account name for flow logs (lowercase, 3-24 chars)."
  type        = string
  default     = "stnsgsecureexample"
}

variable "network_watcher_name" {
  description = "Network Watcher name."
  type        = string
  default     = "nw-nsg-secure-example"
}
