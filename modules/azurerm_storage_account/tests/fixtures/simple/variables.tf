variable "random_suffix" {
  description = "Random suffix for resource naming"
  type        = string
}

variable "location" {
  description = "Azure location for resources"
  type        = string
  default     = "northeurope"
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "enable_blob_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = false
}