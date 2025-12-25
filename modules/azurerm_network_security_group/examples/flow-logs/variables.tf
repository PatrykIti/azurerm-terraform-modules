variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "rg-nsg-flow-logs-example"
}

variable "nsg_name" {
  description = "Network Security Group name."
  type        = string
  default     = "nsg-flow-logs-example"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name."
  type        = string
  default     = "law-nsg-flow-logs-example"
}

variable "storage_account_name" {
  description = "Storage account name for flow logs (lowercase, 3-24 chars)."
  type        = string
  default     = "stnsgflowlogsex"
}

variable "network_watcher_name" {
  description = "Network Watcher name."
  type        = string
  default     = "NetworkWatcher_westeurope"
}

variable "network_watcher_resource_group_name" {
  description = "Network Watcher resource group name."
  type        = string
  default     = "NetworkWatcherRG"
}

variable "enable_flow_log" {
  description = "Enable NSG flow logs (creation may be blocked in some regions/subscriptions due to Azure retirement)."
  type        = bool
  default     = false
}
