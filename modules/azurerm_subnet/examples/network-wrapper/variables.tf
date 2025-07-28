variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-subnet-wrapper-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-subnet-wrapper-example"
}

variable "app_subnet_name" {
  description = "The name of the application subnet"
  type        = string
  default     = "snet-app-wrapper-example"
}

variable "data_subnet_name" {
  description = "The name of the data subnet"
  type        = string
  default     = "snet-data-wrapper-example"
}

variable "mgmt_subnet_name" {
  description = "The name of the management subnet"
  type        = string
  default     = "snet-mgmt-wrapper-example"
}

variable "app_nsg_name" {
  description = "The name of the application NSG"
  type        = string
  default     = "nsg-app-wrapper-example"
}

variable "data_nsg_name" {
  description = "The name of the data NSG"
  type        = string
  default     = "nsg-data-wrapper-example"
}

variable "app_route_table_name" {
  description = "The name of the application route table"
  type        = string
  default     = "rt-app-wrapper-example"
}

variable "data_route_table_name" {
  description = "The name of the data route table"
  type        = string
  default     = "rt-data-wrapper-example"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Example"
    ManagedBy   = "Terraform"
    Purpose     = "NetworkWrapper"
  }
}