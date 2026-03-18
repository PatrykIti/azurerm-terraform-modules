output "id" {
  description = "The ID of the Managed Redis instance."
  value       = try(azurerm_managed_redis.managed_redis.id, null)
}

output "name" {
  description = "The name of the Managed Redis instance."
  value       = try(azurerm_managed_redis.managed_redis.name, null)
}

output "location" {
  description = "The Azure region of the Managed Redis instance."
  value       = try(azurerm_managed_redis.managed_redis.location, null)
}

output "resource_group_name" {
  description = "The resource group containing the Managed Redis instance."
  value       = try(azurerm_managed_redis.managed_redis.resource_group_name, null)
}

output "hostname" {
  description = "The DNS hostname of the Managed Redis instance."
  value       = try(azurerm_managed_redis.managed_redis.hostname, null)
}

output "sku_name" {
  description = "The SKU name of the Managed Redis instance."
  value       = try(azurerm_managed_redis.managed_redis.sku_name, null)
}

output "high_availability_enabled" {
  description = "Whether high availability is enabled for the Managed Redis instance."
  value       = try(azurerm_managed_redis.managed_redis.high_availability_enabled, null)
}

output "public_network_access" {
  description = "The public network access mode of the Managed Redis instance."
  value       = try(azurerm_managed_redis.managed_redis.public_network_access, null)
}

output "identity" {
  description = "Managed identity configuration for the Managed Redis instance."
  value       = try(azurerm_managed_redis.managed_redis.identity[0], null)
}

output "customer_managed_key" {
  description = "Customer-managed key configuration for the Managed Redis instance."
  value       = try(azurerm_managed_redis.managed_redis.customer_managed_key[0], null)
}

output "default_database" {
  description = "Sanitized details of the Managed Redis default database."
  value = length(try(azurerm_managed_redis.managed_redis.default_database, [])) == 0 ? null : {
    id                                            = try(azurerm_managed_redis.managed_redis.default_database[0].id, null)
    port                                          = try(azurerm_managed_redis.managed_redis.default_database[0].port, null)
    access_keys_authentication_enabled            = try(azurerm_managed_redis.managed_redis.default_database[0].access_keys_authentication_enabled, null)
    client_protocol                               = try(azurerm_managed_redis.managed_redis.default_database[0].client_protocol, null)
    clustering_policy                             = try(azurerm_managed_redis.managed_redis.default_database[0].clustering_policy, null)
    eviction_policy                               = try(azurerm_managed_redis.managed_redis.default_database[0].eviction_policy, null)
    geo_replication_group_name                    = try(azurerm_managed_redis.managed_redis.default_database[0].geo_replication_group_name, null)
    persistence_append_only_file_backup_frequency = try(azurerm_managed_redis.managed_redis.default_database[0].persistence_append_only_file_backup_frequency, null)
    persistence_redis_database_backup_frequency   = try(azurerm_managed_redis.managed_redis.default_database[0].persistence_redis_database_backup_frequency, null)
    modules = [
      for redis_module in try(azurerm_managed_redis.managed_redis.default_database[0].module, []) : {
        name    = redis_module.name
        args    = try(redis_module.args, null)
        version = try(redis_module.version, null)
      }
    ]
  }
}

output "default_database_primary_access_key" {
  description = "The primary access key for the default database, when access key authentication is enabled."
  value       = try(azurerm_managed_redis.managed_redis.default_database[0].primary_access_key, null)
  sensitive   = true
}

output "default_database_secondary_access_key" {
  description = "The secondary access key for the default database, when access key authentication is enabled."
  value       = try(azurerm_managed_redis.managed_redis.default_database[0].secondary_access_key, null)
  sensitive   = true
}

output "geo_replication" {
  description = "Geo-replication membership details managed by this module."
  value = try({
    id                       = azurerm_managed_redis_geo_replication.geo_replication[0].id
    managed_redis_id         = azurerm_managed_redis_geo_replication.geo_replication[0].managed_redis_id
    linked_managed_redis_ids = azurerm_managed_redis_geo_replication.geo_replication[0].linked_managed_redis_ids
  }, null)
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no log or metric categories were supplied."
  value = [
    for ds in var.monitoring : {
      name              = ds.name
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if(
      (ds.log_categories == null ? 0 : length(ds.log_categories)) +
      (ds.metric_categories == null ? 0 : length(ds.metric_categories))
    ) == 0
  ]
}

output "tags" {
  description = "The tags assigned to the Managed Redis instance."
  value       = try(azurerm_managed_redis.managed_redis.tags, null)
}
