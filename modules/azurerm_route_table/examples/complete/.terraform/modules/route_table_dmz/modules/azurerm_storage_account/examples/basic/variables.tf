variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-storage-basic-example"
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  default     = "stexamplebasic001"
}