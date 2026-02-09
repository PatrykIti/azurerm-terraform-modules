output "id" {
  description = "The ID of the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.id
}

output "name" {
  description = "The name of the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.name
}

output "resource_group_name" {
  description = "The resource group name of the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.resource_group_name
}

output "location" {
  description = "The location of the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.location
}

output "hostname" {
  description = "The hostname of the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.hostname
}

output "ssl_port" {
  description = "The SSL port of the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.ssl_port
}

output "port" {
  description = "The non-SSL port of the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.port
}

output "primary_access_key" {
  description = "The primary access key for the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.secondary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string for the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The secondary connection string for the Redis Cache."
  value       = azurerm_redis_cache.redis_cache.secondary_connection_string
  sensitive   = true
}

output "identity" {
  description = "The managed identity configuration for the Redis Cache."
  value = try({
    principal_id = azurerm_redis_cache.redis_cache.identity[0].principal_id
    tenant_id    = azurerm_redis_cache.redis_cache.identity[0].tenant_id
    type         = azurerm_redis_cache.redis_cache.identity[0].type
  }, null)
}

output "firewall_rules" {
  description = "Firewall rules created for the Redis Cache."
  value = {
    for name, rule in azurerm_redis_firewall_rule.redis_firewall_rule : name => {
      id       = rule.id
      start_ip = rule.start_ip
      end_ip   = rule.end_ip
    }
  }
}

output "linked_servers" {
  description = "Linked servers created for the Redis Cache."
  value = {
    for name, ls in azurerm_redis_linked_server.redis_linked_server : name => {
      id                               = ls.id
      linked_redis_cache_id            = ls.linked_redis_cache_id
      linked_redis_cache_location      = ls.linked_redis_cache_location
      server_role                      = ls.server_role
      geo_replicated_primary_host_name = ls.geo_replicated_primary_host_name
    }
  }
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no log or metric categories were supplied."
  value       = local.diagnostic_settings_skipped
}
