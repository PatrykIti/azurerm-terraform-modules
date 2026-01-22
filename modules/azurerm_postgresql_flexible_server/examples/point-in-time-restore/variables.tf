variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-pgfs-pitr-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "server_name" {
  description = "PostgreSQL Flexible Server name for the restored server (must be globally unique)."
  type        = string
  default     = "pgfspitrexample001"
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

variable "source_server_id" {
  description = "Source PostgreSQL Flexible Server ID to restore from."
  type        = string
}

variable "restore_time_utc" {
  description = "Point-in-time restore timestamp in UTC (RFC3339)."
  type        = string
}
