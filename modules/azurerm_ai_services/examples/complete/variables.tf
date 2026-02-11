variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "rg-ai-services-complete-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "vnet-ai-services-complete"
}

variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
  default     = "snet-ai-services-complete"
}

variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  type        = string
  default     = "law-ai-services-complete"
}

variable "ai_services_name" {
  description = "The name of the AI Services Account."
  type        = string
  default     = "aiservicescomplete001"
}

variable "sku_name" {
  description = "The SKU name for the AI Services Account."
  type        = string
  default     = "S0"
}

variable "custom_subdomain_name" {
  description = "Custom subdomain name required for network ACLs."
  type        = string
  default     = "aiservicescomplete001"
}

variable "allowed_ip_range" {
  description = "IP range allowed to access the AI Services Account."
  type        = string
  default     = "203.0.113.0/24"
}

variable "diagnostic_setting_name" {
  description = "The name of the diagnostic setting."
  type        = string
  default     = "ai-services-diagnostics"
}
