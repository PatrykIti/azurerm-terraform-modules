variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-app-service-plan-complete-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "service_plan_name" {
  description = "App Service Plan name for the example."
  type        = string
  default     = "asp-complete-example"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name used for diagnostics."
  type        = string
  default     = "law-asp-complete-example"
}
