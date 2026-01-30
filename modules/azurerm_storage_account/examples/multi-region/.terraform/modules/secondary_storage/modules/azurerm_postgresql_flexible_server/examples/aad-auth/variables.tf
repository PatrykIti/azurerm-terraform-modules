variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-pgfs-aad-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "server_name" {
  description = "PostgreSQL Flexible Server name (must be globally unique)."
  type        = string
  default     = "pgfsaadexample001"
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

variable "aad_admin_object_id" {
  description = "Object ID of the Azure AD principal to assign as admin."
  type        = string
}

variable "aad_admin_principal_name" {
  description = "Principal name (UPN or group name) for the Azure AD admin."
  type        = string
}

variable "aad_admin_principal_type" {
  description = "Principal type for the Azure AD admin."
  type        = string
  default     = "User"
}
