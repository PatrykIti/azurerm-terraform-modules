variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-network-wrapper-example"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-network-wrapper-example"
}

variable "network_security_group_name" {
  description = "The name of the network security group"
  type        = string
  default     = "nsg-network-wrapper-example"
}

variable "route_table_name" {
  description = "The name of the route table"
  type        = string
  default     = "rt-network-wrapper-example"
}

variable "subnet_prefix" {
  description = "Prefix for subnet names"
  type        = string
  default     = "snet"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default = {
    Environment = "Example"
    ManagedBy   = "Terraform"
    Module      = "azurerm_route_table"
    Example     = "network-wrapper"
  }
}