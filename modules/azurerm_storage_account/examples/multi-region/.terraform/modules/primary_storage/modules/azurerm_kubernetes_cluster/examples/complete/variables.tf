variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-aks-complete-example"
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-aks-complete-example"
}

variable "nodes_subnet_name" {
  description = "Name of the subnet for AKS nodes"
  type        = string
  default     = "snet-aks-nodes-example"
}

variable "pods_subnet_name" {
  description = "Name of the subnet for AKS pods"
  type        = string
  default     = "snet-aks-pods-example"
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
  default     = "nsg-aks-nodes-example"
}

variable "user_assigned_identity_name" {
  description = "Name of the user assigned identity"
  type        = string
  default     = "uai-aks-complete-example"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-complete-example"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks-complete-example"
}

variable "node_resource_group_name" {
  description = "Name of the node resource group"
  type        = string
  default     = "rg-aks-nodes-example"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "law-aks-complete-example"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the cluster"
  type        = string
  default     = "1.30.12"
}

variable "authorized_ip_ranges" {
  description = "List of authorized IP ranges to access the API server"
  type        = list(string)
  default     = []
}

variable "tenant_id" {
  description = "Azure AD tenant ID for RBAC configuration"
  type        = string
  default     = null
}

variable "admin_group_object_ids" {
  description = "Azure AD group object IDs that will have admin access to the cluster"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "AKS-Complete-Example"
  }
}
