variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "rg-ai-services-basic-example"
}

variable "ai_services_name" {
  description = "The name of the AI Services Account."
  type        = string
  default     = "aiservicesbasic001"
}

variable "sku_name" {
  description = "The SKU name for the AI Services Account."
  type        = string
  default     = "S0"
}
