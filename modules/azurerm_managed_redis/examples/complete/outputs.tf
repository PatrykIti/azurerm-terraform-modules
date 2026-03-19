output "managed_redis_id" {
  description = "The ID of the Managed Redis instance."
  value       = module.managed_redis.id
}

output "managed_redis_hostname" {
  description = "The hostname of the Managed Redis instance."
  value       = module.managed_redis.hostname
}

output "default_database" {
  description = "Sanitized information about the default database."
  value       = module.managed_redis.default_database
}
