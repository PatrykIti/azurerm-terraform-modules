variable "resource_group_name" {
  description = "Name of the resource group for the example."
  type        = string
  default     = "rg-pgfsdb-secure-example"
}

variable "location" {
  description = "Azure region for the example."
  type        = string
  default     = "westeurope"
}

variable "virtual_network_name" {
  description = "Virtual network name for the private server."
  type        = string
  default     = "vnet-pgfsdb-secure-example"
}

variable "subnet_name" {
  description = "Delegated subnet name for the private server."
  type        = string
  default     = "snet-pgfsdb-secure-example"
}

variable "server_name" {
  description = "PostgreSQL Flexible Server name (must be globally unique)."
  type        = string
  default     = "pgfsdbsecureexample001"
}

variable "database_name" {
  description = "PostgreSQL database name."
  type        = string
  default     = "appdbsecure"
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
