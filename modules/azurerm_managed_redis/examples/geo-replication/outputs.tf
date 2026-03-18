output "primary_managed_redis_id" {
  description = "The ID of the primary Managed Redis instance."
  value       = module.managed_redis_primary.id
}

output "secondary_managed_redis_id" {
  description = "The ID of the secondary Managed Redis instance."
  value       = module.managed_redis_secondary.id
}

output "primary_geo_replication" {
  description = "Geo-replication membership managed on the primary instance."
  value       = module.managed_redis_primary.geo_replication
}
