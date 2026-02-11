variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "rg-bastion-diagnostic-settings-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "vnet-bastion-diagnostic-settings-example"
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for AzureBastionSubnet (minimum /26)."
  type        = string
  default     = "10.80.0.0/26"
}

variable "public_ip_name" {
  description = "The name of the public IP address."
  type        = string
  default     = "pip-bastion-diagnostic-settings-example"
}

variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  type        = string
  default     = "law-bastion-diagnostic-settings-example"
}

variable "bastion_name" {
  description = "The name of the Bastion Host."
  type        = string
  default     = "bastion-diagnostic-settings-example"
}

variable "ip_configuration_name" {
  description = "The name of the Bastion IP configuration."
  type        = string
  default     = "bastion-diagnostic-settings-ipconfig"
}
