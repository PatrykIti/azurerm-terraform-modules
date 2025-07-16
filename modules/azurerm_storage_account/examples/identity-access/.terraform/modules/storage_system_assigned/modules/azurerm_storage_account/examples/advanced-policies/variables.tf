variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-storage-advanced-policies"
}

variable "storage_account_name_prefix" {
  description = "Prefix for the storage account name"
  type        = string
  default     = "stadvpolicies"
}

variable "custom_domain_name" {
  description = "Custom domain name for the storage account (requires DNS CNAME record)"
  type        = string
  default     = ""
}