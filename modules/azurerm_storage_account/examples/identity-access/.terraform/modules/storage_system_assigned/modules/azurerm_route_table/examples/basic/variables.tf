variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-rt-basic-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-rt-basic-example"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "snet-rt-basic-example"
}

variable "route_table_name" {
  description = "The name of the route table"
  type        = string
  default     = "rt-basic-example"
}