variable "primary_location" {
  description = "Azure region for the primary Redis Cache."
  type        = string
  default     = "westeurope"
}

variable "secondary_location" {
  description = "Azure region for the secondary Redis Cache."
  type        = string
  default     = "northeurope"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "rg-redis-linked-example"
}

variable "primary_cache_name" {
  description = "The name of the primary Redis Cache."
  type        = string
  default     = "redis-linked-primary"
}

variable "secondary_cache_name" {
  description = "The name of the secondary Redis Cache."
  type        = string
  default     = "redis-linked-secondary"
}
