variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-subnet-complete-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-subnet-complete-example"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "snet-complete-example"
}

variable "subnet_no_delegation_name" {
  description = "The name of the subnet without delegation"
  type        = string
  default     = "snet-nodeleg-example"
}

variable "nsg_name" {
  description = "The name of the network security group"
  type        = string
  default     = "nsg-subnet-complete-example"
}

variable "route_table_name" {
  description = "The name of the route table"
  type        = string
  default     = "rt-subnet-complete-example"
}

variable "service_endpoint_policy_name" {
  description = "The name of the service endpoint policy"
  type        = string
  default     = "sep-subnet-complete-example"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Example     = "Complete"
    Module      = "azurerm_subnet"
  }
}