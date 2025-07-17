variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
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
