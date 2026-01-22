variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-pgfs-complete-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "server_name" {
  description = "PostgreSQL Flexible Server name (must be globally unique)."
  type        = string
  default     = "pgfscompleteexample001"
}

variable "administrator_login" {
  description = "Administrator login for the PostgreSQL Flexible Server."
  type        = string
  default     = "pgfsadmin"
}

variable "sku_name" {
  description = "SKU name for the PostgreSQL Flexible Server."
  type        = string
  default     = "Standard_D4s_v3"
}

variable "postgresql_version" {
  description = "PostgreSQL version for the server."
  type        = string
  default     = "15"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace for diagnostics."
  type        = string
  default     = "law-pgfs-complete-example"
}
