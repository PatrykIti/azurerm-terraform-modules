output "redis_cache_id" {
  description = "The ID of the Redis Cache."
  value       = module.redis_cache.id
}

output "redis_cache_name" {
  description = "The name of the Redis Cache."
  value       = module.redis_cache.name
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.example.name
}
