variable "random_suffix" {
  description = "Random suffix for resource naming."
  type        = string
}

variable "location" {
  description = "Primary Azure region for resources."
  type        = string
  default     = "westeurope"
}

variable "secondary_location" {
  description = "Secondary Azure region for the linked Managed Redis instance."
  type        = string
  default     = "centralus"
}

variable "geo_replication_group_name" {
  description = "Geo-replication group name shared by the linked instances."
  type        = string
  default     = "managed-redis-test-group"
}
