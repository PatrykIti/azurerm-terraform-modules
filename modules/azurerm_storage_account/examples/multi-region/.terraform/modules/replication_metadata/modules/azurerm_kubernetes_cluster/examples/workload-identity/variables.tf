variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-aks-workload-id-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-aks-workload-id-example"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "snet-aks-nodes-example"
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "aks-workload-id-example"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks-workload-id-example"
}

variable "aks_admins_group_name" {
  description = "The name of the Azure AD group for AKS administrators"
  type        = string
  default     = "aks-workload-id-admins-example"
}

variable "workload_identity_name" {
  description = "The name of the user-assigned managed identity for workload identity"
  type        = string
  default     = "id-workload-example"
}

variable "key_vault_name" {
  description = "The name of the Key Vault for demonstrating workload identity access"
  type        = string
  default     = "kvakswlidexample"
}