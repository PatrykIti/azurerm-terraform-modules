variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "North Europe"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-aks-secure-example"
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-aks-secure-example"
}

variable "subnet_name" {
  description = "Name of the subnet for AKS nodes"
  type        = string
  default     = "snet-aks-nodes-example"
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
  default     = "nsg-aks-nodes-example"
}

variable "user_assigned_identity_name" {
  description = "Name of the user assigned identity"
  type        = string
  default     = "uai-aks-secure-example"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-secure-example"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks-secure-example"
}

variable "node_resource_group_name" {
  description = "Name of the node resource group"
  type        = string
  default     = "rg-aks-nodes-secure-example"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "law-aks-secure-example"
}
