variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-aks-basic-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-aks-basic-example"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "snet-aks-nodes-example"
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "aks-basic-example"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks-basic-example"
}
