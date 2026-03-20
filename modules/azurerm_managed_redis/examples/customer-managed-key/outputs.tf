output "managed_redis_id" {
  description = "The ID of the Managed Redis instance."
  value       = module.managed_redis.id
}

output "customer_managed_key" {
  description = "The customer-managed key configuration."
  value       = module.managed_redis.customer_managed_key
}
