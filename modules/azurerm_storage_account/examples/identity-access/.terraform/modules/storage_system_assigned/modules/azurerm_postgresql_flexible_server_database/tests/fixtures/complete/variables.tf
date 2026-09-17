variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "sku_name" {
  description = "SKU name for the PostgreSQL Flexible Server."
  type        = string
  default     = "GP_Standard_D4s_v3"
}

variable "postgresql_version" {
  description = "PostgreSQL version for the server."
  type        = string
  default     = "15"
}
