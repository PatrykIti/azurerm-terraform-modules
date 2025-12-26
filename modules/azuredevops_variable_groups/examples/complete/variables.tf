variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "key_vault_service_endpoint_id" {
  description = "Service endpoint ID for the Key Vault integration."
  type        = string
}

variable "principal_descriptor" {
  description = "Principal descriptor for variable group permissions."
  type        = string
}

variable "library_principal_descriptor" {
  description = "Principal descriptor for library permissions."
  type        = string
}
