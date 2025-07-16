variable "random_suffix" {
  description = "Random suffix for resource naming"
  type        = string
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "northeurope"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "storage_account_suffix" {
  description = "Additional suffix for storage account name"
  type        = string
  default     = ""
}

variable "enable_blob_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = false
}