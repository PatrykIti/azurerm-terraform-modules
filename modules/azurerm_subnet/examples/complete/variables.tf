# Variables for Complete Subnet Example

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "storage_account_name" {
  description = "Storage account name used for the service endpoint policy example."
  type        = string
  default     = "stsubnetcompleteexample"
}
