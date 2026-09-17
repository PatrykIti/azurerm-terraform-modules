variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-rt-complete-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-hub-complete-example"
}

variable "subnet_app_name" {
  description = "The name of the application subnet"
  type        = string
  default     = "snet-app-example"
}

variable "subnet_data_name" {
  description = "The name of the data subnet"
  type        = string
  default     = "snet-data-example"
}

variable "route_table_hub_name" {
  description = "The name of the hub route table"
  type        = string
  default     = "rt-hub-complete-example"
}

variable "route_table_dmz_name" {
  description = "The name of the DMZ route table"
  type        = string
  default     = "rt-dmz-example"
}