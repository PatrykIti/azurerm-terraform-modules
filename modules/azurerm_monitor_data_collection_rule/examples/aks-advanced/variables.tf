variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-dcr-aks-advanced-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "vnet-dcr-aks-advanced-example"
}

variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
  default     = "snet-dcr-aks-advanced"
}

variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
  default     = "aks-dcr-advanced-example"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
  default     = "aks-dcr-advanced"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name for the example."
  type        = string
  default     = "law-dcr-aks-advanced-example"
}

variable "data_collection_endpoint_name" {
  description = "Data Collection Endpoint name for the example."
  type        = string
  default     = "dce-dcr-aks-advanced-example"
}

variable "data_collection_rule_name" {
  description = "Data Collection Rule name for the example."
  type        = string
  default     = "dcr-aks-advanced-example"
}
