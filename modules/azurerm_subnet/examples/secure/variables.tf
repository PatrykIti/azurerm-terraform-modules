variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-subnet-secure-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-subnet-secure-example"
}

variable "app_subnet_name" {
  description = "The name of the application subnet"
  type        = string
  default     = "snet-app-secure-example"
}

variable "db_subnet_name" {
  description = "The name of the database subnet"
  type        = string
  default     = "snet-db-secure-example"
}

variable "bastion_subnet_name" {
  description = "The name of the bastion subnet"
  type        = string
  default     = "AzureBastionSubnet"
}

variable "nsg_name" {
  description = "The name of the network security group"
  type        = string
  default     = "nsg-subnet-secure-example"
}

variable "route_table_name" {
  description = "The name of the route table"
  type        = string
  default     = "rt-subnet-secure-example"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment   = "Production"
    Example       = "Secure"
    Module        = "azurerm_subnet"
    SecurityLevel = "High"
  }
}