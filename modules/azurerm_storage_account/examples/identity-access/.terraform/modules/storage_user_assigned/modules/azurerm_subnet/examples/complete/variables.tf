# Variables for Complete Subnet Example

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-subnet-complete-example"
}

variable "virtual_network_name" {
  description = "The name of the Virtual Network"
  type        = string
  default     = "vnet-subnet-complete-example"
}

variable "subnet_name" {
  description = "The name of the Subnet"
  type        = string
  default     = "snet-subnet-complete-example"
}

variable "network_security_group_name" {
  description = "The name of the Network Security Group"
  type        = string
  default     = "nsg-subnet-complete-example"
}

variable "route_table_name" {
  description = "The name of the Route Table"
  type        = string
  default     = "rt-subnet-complete-example"
}

variable "service_endpoint_policy_name" {
  description = "The name of the Service Endpoint Policy"
  type        = string
  default     = "sep-subnet-complete-example"
}

variable "storage_account_name" {
  description = "Storage account name used for the service endpoint policy example."
  type        = string
  default     = "stsubnetcompleteexample"
}
