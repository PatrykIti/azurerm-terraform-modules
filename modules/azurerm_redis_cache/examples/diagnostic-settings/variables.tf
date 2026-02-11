variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "rg-redis-diagnostics-example"
}

variable "redis_cache_name" {
  description = "The name of the Redis Cache."
  type        = string
  default     = "redis-diag-example"
}

variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  type        = string
  default     = "law-redis-diag-example"
}
