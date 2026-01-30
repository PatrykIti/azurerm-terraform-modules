# Variables for Secure Subnet Example

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-subnet-secure-example"
}

variable "virtual_network_name" {
  description = "The name of the Virtual Network"
  type        = string
  default     = "vnet-subnet-secure-example"
}

variable "subnet_name" {
  description = "The name of the Subnet"
  type        = string
  default     = "snet-subnet-secure-example"
}

variable "network_security_group_name" {
  description = "The name of the Network Security Group"
  type        = string
  default     = "nsg-subnet-secure-example"
}
