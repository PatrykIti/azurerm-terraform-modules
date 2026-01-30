output "id" {
  description = "The Event Hub Namespace ID."
  value       = azurerm_eventhub_namespace.namespace.id
}

output "name" {
  description = "The name of the Event Hub Namespace."
  value       = azurerm_eventhub_namespace.namespace.name
}

output "resource_group_name" {
  description = "The resource group name of the Event Hub Namespace."
  value       = var.resource_group_name
}

output "location" {
  description = "The location of the Event Hub Namespace."
  value       = azurerm_eventhub_namespace.namespace.location
}

output "sku" {
  description = "The SKU of the Event Hub Namespace."
  value       = azurerm_eventhub_namespace.namespace.sku
}

output "capacity" {
  description = "The capacity (throughput units) for the Event Hub Namespace."
  value       = azurerm_eventhub_namespace.namespace.capacity
}

output "auto_inflate_enabled" {
  description = "Whether auto inflate is enabled."
  value       = azurerm_eventhub_namespace.namespace.auto_inflate_enabled
}

output "maximum_throughput_units" {
  description = "The maximum throughput units when auto inflate is enabled."
  value       = azurerm_eventhub_namespace.namespace.maximum_throughput_units
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = azurerm_eventhub_namespace.namespace.public_network_access_enabled
}

output "local_authentication_enabled" {
  description = "Whether SAS authentication is enabled."
  value       = azurerm_eventhub_namespace.namespace.local_authentication_enabled
}

output "minimum_tls_version" {
  description = "The minimum TLS version for the namespace."
  value       = azurerm_eventhub_namespace.namespace.minimum_tls_version
}

output "identity" {
  description = "The managed identity configuration for the namespace."
  value       = azurerm_eventhub_namespace.namespace.identity
}

output "authorization_rules" {
  description = "Authorization rules created for the namespace."
  value = {
    for name, rule in azurerm_eventhub_namespace_authorization_rule.authorization_rules : name => {
      id                                = rule.id
      listen                            = rule.listen
      send                              = rule.send
      manage                            = rule.manage
      primary_connection_string         = rule.primary_connection_string
      primary_connection_string_alias   = rule.primary_connection_string_alias
      primary_key                       = rule.primary_key
      secondary_connection_string       = rule.secondary_connection_string
      secondary_connection_string_alias = rule.secondary_connection_string_alias
      secondary_key                     = rule.secondary_key
    }
  }
  sensitive = true
}

output "default_primary_connection_string" {
  description = "The primary connection string for RootManageSharedAccessKey, if present."
  value       = azurerm_eventhub_namespace.namespace.default_primary_connection_string
  sensitive   = true
}

output "default_secondary_connection_string" {
  description = "The secondary connection string for RootManageSharedAccessKey, if present."
  value       = azurerm_eventhub_namespace.namespace.default_secondary_connection_string
  sensitive   = true
}

output "default_primary_key" {
  description = "The primary key for RootManageSharedAccessKey, if present."
  value       = azurerm_eventhub_namespace.namespace.default_primary_key
  sensitive   = true
}

output "default_secondary_key" {
  description = "The secondary key for RootManageSharedAccessKey, if present."
  value       = azurerm_eventhub_namespace.namespace.default_secondary_key
  sensitive   = true
}

output "disaster_recovery_config_id" {
  description = "The ID of the disaster recovery configuration, if configured."
  value       = try(values(azurerm_eventhub_namespace_disaster_recovery_config.disaster_recovery)[0].id, null)
}

output "customer_managed_key_id" {
  description = "The ID of the customer managed key association, if configured."
  value       = try(azurerm_eventhub_namespace_customer_managed_key.customer_managed_key[0].id, null)
}

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no log or metric categories were supplied."
  value       = local.diagnostic_settings_skipped
}
