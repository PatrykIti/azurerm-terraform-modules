variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "rg-redis-complete-example"
}

variable "redis_cache_name" {
  description = "The name of the Redis Cache."
  type        = string
  default     = "redis-complete-example"
}

variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  type        = string
  default     = "law-redis-complete-example"
}

variable "storage_account_name" {
  description = "The name of the storage account for persistence."
  type        = string
  default     = "strediscomplete"
}
