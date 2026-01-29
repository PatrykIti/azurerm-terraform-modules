variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-appins-basic-example"
}

variable "application_insights_name" {
  description = "Name of the Application Insights component."
  type        = string
  default     = "appi-basic-example"
}
