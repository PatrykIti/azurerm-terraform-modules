variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-dcr-syslog-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "data_collection_rule_name" {
  description = "Data Collection Rule name (must be globally unique)."
  type        = string
  default     = "dcrsyslogexample001"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name for the example."
  type        = string
  default     = "lawdcrsyslogexample001"
}
