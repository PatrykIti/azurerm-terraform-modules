variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-ampls-complete-example"
}

variable "scope_name" {
  description = "Name of the Azure Monitor Private Link Scope."
  type        = string
  default     = "ampls-complete-example"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name."
  type        = string
  default     = "law-ampls-complete-example"
}

variable "application_insights_name" {
  description = "Application Insights name."
  type        = string
  default     = "appi-ampls-complete-example"
}

variable "data_collection_endpoint_name" {
  description = "Data Collection Endpoint name."
  type        = string
  default     = "dce-ampls-complete-example"
}
