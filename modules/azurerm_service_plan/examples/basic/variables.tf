variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-app-service-plan-basic-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "service_plan_name" {
  description = "App Service Plan name for the example."
  type        = string
  default     = "asp-basic-example"
}

variable "os_type" {
  description = "Operating system type for the App Service Plan."
  type        = string
  default     = "Windows"
}

variable "sku_name" {
  description = "SKU name for the App Service Plan."
  type        = string
  default     = "B1"
}
