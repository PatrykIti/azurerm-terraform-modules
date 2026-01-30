variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "rg-bastion-secure-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "vnet-bastion-secure-example"
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for AzureBastionSubnet (minimum /26)."
  type        = string
  default     = "10.30.0.0/26"
}

variable "network_security_group_name" {
  description = "The name of the network security group applied to the Bastion subnet."
  type        = string
  default     = "nsg-bastion-secure-example"
}

variable "public_ip_name" {
  description = "The name of the public IP address."
  type        = string
  default     = "pip-bastion-secure-example"
}

variable "bastion_name" {
  description = "The name of the Bastion Host."
  type        = string
  default     = "bastion-secure-example"
}

variable "ip_configuration_name" {
  description = "The name of the Bastion IP configuration."
  type        = string
  default     = "bastion-secure-ipconfig"
}
