# Variables for Private Endpoint Subnet Example

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-subnet-private-endpoint-example"
}

variable "virtual_network_name" {
  description = "The name of the Virtual Network"
  type        = string
  default     = "vnet-subnet-private-endpoint-example"
}

variable "subnet_name" {
  description = "The name of the Subnet"
  type        = string
  default     = "snet-subnet-private-endpoint-example"
}

variable "private_endpoint_name" {
  description = "The name of the private endpoint"
  type        = string
  default     = "pe-subnet-private-endpoint-example"
}

variable "storage_account_name" {
  description = "Storage account name used for the private endpoint example."
  type        = string
  default     = "stsubnetprivateendpoint"
}
