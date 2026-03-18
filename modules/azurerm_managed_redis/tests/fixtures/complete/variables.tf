variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "geo_replication_group_name" {
  description = "Geo-replication group name for the default database."
  type        = string
  default     = "managed-redis-test-group"
}

variable "tags" {
  description = "Tags to apply to the Managed Redis instance."
  type        = map(string)
  default = {
    Environment = "Test"
    Example     = "Complete"
  }
}
