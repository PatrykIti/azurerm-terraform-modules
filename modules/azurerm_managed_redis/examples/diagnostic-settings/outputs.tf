output "managed_redis_id" {
  description = "The ID of the Managed Redis instance."
  value       = module.managed_redis.id
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped by the module."
  value       = module.managed_redis.diagnostic_settings_skipped
}
