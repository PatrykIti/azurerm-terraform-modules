variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-pgfs-cmk-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "server_name" {
  description = "PostgreSQL Flexible Server name (must be globally unique)."
  type        = string
  default     = "pgfscmkexample001"
}

variable "administrator_login" {
  description = "Administrator login for the PostgreSQL Flexible Server."
  type        = string
  default     = "pgfsadmin"
}

variable "sku_name" {
  description = "SKU name for the PostgreSQL Flexible Server."
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "postgresql_version" {
  description = "PostgreSQL version for the server."
  type        = string
  default     = "15"
}

variable "user_assigned_identity_name" {
  description = "User-assigned identity name for CMK access."
  type        = string
  default     = "uai-pgfs-cmk-example"
}

variable "key_vault_name" {
  description = "Key Vault name for customer-managed keys (must be globally unique)."
  type        = string
  default     = "kvpgfscmkexample01"
}
