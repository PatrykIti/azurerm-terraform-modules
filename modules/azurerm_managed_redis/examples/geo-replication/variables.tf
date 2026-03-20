variable "primary_location" {
  description = "Primary region for the first Managed Redis instance."
  type        = string
  default     = "westeurope"
}

variable "secondary_location" {
  description = "Secondary region for the linked Managed Redis instance."
  type        = string
  default     = "centralus"
}

variable "geo_replication_group_name" {
  description = "Geo-replication group name shared by both Managed Redis instances."
  type        = string
  default     = "managed-redis-geo-example-group"
}
