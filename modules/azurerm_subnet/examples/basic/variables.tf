variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-subnet-basic-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-subnet-basic-example"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "snet-basic-example"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Example     = "Basic"
    Module      = "azurerm_subnet"
  }
}