# Variables for Basic Subnet Example

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-subnet-basic-example"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "virtual_network_name" {
  description = "The name of the Virtual Network"
  type        = string
  default     = "vnet-subnet-basic-example"
}

variable "subnet_name" {
  description = "The name of the Subnet"
  type        = string
  default     = "subnet-basic-example"
}