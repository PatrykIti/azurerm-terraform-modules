variable "location" {
  description = "Azure region for the example resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Resource group name for the example."
  type        = string
  default     = "rg-managed-redis-cmk-example"
}

variable "user_assigned_identity_name" {
  description = "User-assigned identity name for the example."
  type        = string
  default     = "uai-managed-redis-cmk"
}

variable "key_vault_name" {
  description = "Key Vault name for the example."
  type        = string
  default     = "kvmanagedrediscmk001"
}
