variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "rg-redis-secure-example"
}

variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "vnet-redis-secure-example"
}

variable "redis_cache_name" {
  description = "The name of the Redis Cache."
  type        = string
  default     = "redis-secure-example"
}
