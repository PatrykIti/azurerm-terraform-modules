output "managed_redis_id" {
  description = "The ID of the Managed Redis instance."
  value       = module.managed_redis.id
}

output "managed_redis_name" {
  description = "The name of the Managed Redis instance."
  value       = module.managed_redis.name
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.example.name
}

output "default_database_port" {
  description = "The default database port."
  value       = try(module.managed_redis.default_database.port, null)
}
