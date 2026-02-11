variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "rg-ai-services-secure-example"
}

variable "ai_services_name" {
  description = "The name of the AI Services Account."
  type        = string
  default     = "aiservicessecure001"
}

variable "sku_name" {
  description = "The SKU name for the AI Services Account."
  type        = string
  default     = "S0"
}

variable "user_assigned_identity_name" {
  description = "The name of the user-assigned identity."
  type        = string
  default     = "id-ai-services-secure"
}

variable "key_vault_name" {
  description = "The name of the Key Vault."
  type        = string
  default     = "kv-aisecure-001"
}

variable "key_vault_key_name" {
  description = "The name of the Key Vault key."
  type        = string
  default     = "ai-services-key"
}

variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  type        = string
  default     = "law-ai-services-secure"
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "vnet-ai-services-secure"
}

variable "private_endpoint_subnet_name" {
  description = "The name of the private endpoint subnet."
  type        = string
  default     = "snet-ai-services-private-endpoints"
}

variable "private_endpoint_name" {
  description = "The name of the private endpoint."
  type        = string
  default     = "pe-ai-services-secure"
}

variable "diagnostic_setting_name" {
  description = "The name of the diagnostic setting."
  type        = string
  default     = "ai-services-secure-diagnostics"
}
