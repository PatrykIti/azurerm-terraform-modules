output "managed_redis_id" {
  description = "The ID of the Managed Redis instance."
  value       = module.managed_redis.id
}

output "managed_redis_name" {
  description = "The name of the Managed Redis instance."
  value       = module.managed_redis.name
}

output "managed_redis_hostname" {
  description = "The hostname of the Managed Redis instance."
  value       = module.managed_redis.hostname
}
