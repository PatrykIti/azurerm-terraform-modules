output "primary_managed_redis_id" {
  description = "The ID of the primary Managed Redis instance."
  value       = module.managed_redis_primary.id
}

output "secondary_managed_redis_id" {
  description = "The ID of the secondary Managed Redis instance."
  value       = module.managed_redis_secondary.id
}

output "geo_replication_linked_ids" {
  description = "The linked Managed Redis IDs managed by the primary module."
  value       = module.managed_redis_primary.geo_replication.linked_managed_redis_ids
}
