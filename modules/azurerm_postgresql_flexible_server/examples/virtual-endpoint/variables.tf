variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-pgfs-virtual-endpoint-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "primary_server_name" {
  description = "Primary PostgreSQL Flexible Server name (must be globally unique)."
  type        = string
  default     = "pgfsveprimary001"
}

variable "replica_server_name" {
  description = "Replica PostgreSQL Flexible Server name (must be globally unique)."
  type        = string
  default     = "pgfsvereplica001"
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
