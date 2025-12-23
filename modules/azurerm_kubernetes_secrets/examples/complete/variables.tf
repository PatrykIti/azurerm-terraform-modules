variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-aks-secrets-complete-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-aks-secrets-complete-example"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "snet-aks-secrets-complete-example"
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "aks-secrets-complete-example"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks-secrets-complete-example"
}

variable "key_vault_name" {
  description = "Key Vault name (must be globally unique; adjust if needed)"
  type        = string
  default     = "kv-aks-secrets-complete"
}
