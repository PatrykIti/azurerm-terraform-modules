output "primary_cache_id" {
  description = "The ID of the primary Redis Cache."
  value       = module.redis_primary.id
}

output "secondary_cache_id" {
  description = "The ID of the secondary Redis Cache."
  value       = module.redis_secondary.id
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.example.name
}
