# Variables for Private Endpoint Subnet Example

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "storage_account_name" {
  description = "Storage account name used for the private endpoint example."
  type        = string
  default     = "stsubnetpeexample"
}
