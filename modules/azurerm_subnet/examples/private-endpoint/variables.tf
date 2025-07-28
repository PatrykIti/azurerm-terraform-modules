variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-subnet-pe-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-subnet-pe-example"
}

variable "subnet_name" {
  description = "The name of the private endpoint subnet"
  type        = string
  default     = "snet-pe-example"
}

variable "nsg_name" {
  description = "The name of the network security group"
  type        = string
  default     = "nsg-subnet-pe-example"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Example     = "Private-Endpoint"
    Module      = "azurerm_subnet"
  }
}