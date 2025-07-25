variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-network-wrapper-adv-example"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-network-wrapper-adv-example"
}

variable "network_security_group_name" {
  description = "The name of the network security group"
  type        = string
  default     = "nsg-network-wrapper-adv-example"
}

variable "route_table_name" {
  description = "The name of the route table"
  type        = string
  default     = "rt-network-wrapper-adv-example"
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    address_prefix         = string
    associate_route_table  = bool
    associate_nsg         = bool
  }))
  default = {
    "snet-app" = {
      address_prefix        = "10.0.1.0/24"
      associate_route_table = true
      associate_nsg        = true
    }
    "snet-data" = {
      address_prefix        = "10.0.2.0/24"
      associate_route_table = true
      associate_nsg        = true
    }
    "snet-gateway" = {
      address_prefix        = "10.0.3.0/24"
      associate_route_table = false  # Gateway subnets typically don't need route tables
      associate_nsg        = false  # Gateway subnets can't have NSGs
    }
    "snet-management" = {
      address_prefix        = "10.0.4.0/24"
      associate_route_table = false
      associate_nsg        = true
    }
  }
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default = {
    Environment = "Example"
    ManagedBy   = "Terraform"
    Module      = "azurerm_route_table"
    Example     = "network-wrapper-advanced"
  }
}