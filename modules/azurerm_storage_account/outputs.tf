output "id" {
  description = "The ID of the Storage Account"
  value       = try(azurerm_storage_account.storage_account.id, null)
}

output "name" {
  description = "The name of the Storage Account"
  value       = try(azurerm_storage_account.storage_account.name, null)
}

output "primary_location" {
  description = "The primary location of the storage account"
  value       = try(azurerm_storage_account.storage_account.primary_location, null)
}

output "secondary_location" {
  description = "The secondary location of the storage account, if configured"
  value       = try(azurerm_storage_account.storage_account.secondary_location, null)
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_blob_endpoint, null)
}

output "primary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_blob_host, null)
}

output "secondary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_blob_endpoint, null)
}

output "secondary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_blob_host, null)
}

output "primary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_queue_endpoint, null)
}

output "secondary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_queue_endpoint, null)
}

output "primary_table_endpoint" {
  description = "The endpoint URL for table storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_table_endpoint, null)
}

output "secondary_table_endpoint" {
  description = "The endpoint URL for table storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_table_endpoint, null)
}

output "primary_file_endpoint" {
  description = "The endpoint URL for file storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_file_endpoint, null)
}

output "secondary_file_endpoint" {
  description = "The endpoint URL for file storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_file_endpoint, null)
}

output "primary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_dfs_endpoint, null)
}

output "secondary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_dfs_endpoint, null)
}

output "primary_web_endpoint" {
  description = "The endpoint URL for web storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_web_endpoint, null)
}

output "secondary_web_endpoint" {
  description = "The endpoint URL for web storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_web_endpoint, null)
}

output "primary_web_host" {
  description = "The hostname with port if applicable for web storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_web_host, null)
}

output "secondary_web_host" {
  description = "The hostname with port if applicable for web storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_web_host, null)
}

output "primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = try(azurerm_storage_account.storage_account.primary_connection_string, null)
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The secondary connection string for the storage account"
  value       = try(azurerm_storage_account.storage_account.secondary_connection_string, null)
  sensitive   = true
}

output "primary_blob_connection_string" {
  description = "The primary blob connection string for the storage account"
  value       = try(azurerm_storage_account.storage_account.primary_blob_connection_string, null)
  sensitive   = true
}

output "secondary_blob_connection_string" {
  description = "The secondary blob connection string for the storage account"
  value       = try(azurerm_storage_account.storage_account.secondary_blob_connection_string, null)
  sensitive   = true
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = try(azurerm_storage_account.storage_account.primary_access_key, null)
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the storage account"
  value       = try(azurerm_storage_account.storage_account.secondary_access_key, null)
  sensitive   = true
}

output "identity" {
  description = "The identity block of the storage account"
  value = try({
    type         = azurerm_storage_account.storage_account.identity[0].type
    principal_id = azurerm_storage_account.storage_account.identity[0].principal_id
    tenant_id    = azurerm_storage_account.storage_account.identity[0].tenant_id
    identity_ids = azurerm_storage_account.storage_account.identity[0].identity_ids
  }, null)
}

output "private_endpoints" {
  description = "Map of private endpoints created for the storage account, keyed by endpoint name"
  value = length(azurerm_private_endpoint.private_endpoint) > 0 ? {
    for k, v in azurerm_private_endpoint.private_endpoint : k => {
      id                 = v.id
      name               = v.name
      private_ip_address = v.private_service_connection[0].private_ip_address
      subresource_names  = v.private_service_connection[0].subresource_names
      network_interface = {
        id   = v.network_interface[0].id
        name = v.network_interface[0].name
      }
      custom_dns_configs = [
        for config in v.custom_dns_configs : {
          fqdn         = config.fqdn
          ip_addresses = config.ip_addresses
        }
      ]
      private_dns_zone_configs = [
        for config in v.private_dns_zone_configs : {
          name                = config.name
          id                  = config.id
          private_dns_zone_id = config.private_dns_zone_id
          record_sets = [
            for rs in config.record_sets : {
              name         = rs.name
              type         = rs.type
              fqdn         = rs.fqdn
              ttl          = rs.ttl
              ip_addresses = rs.ip_addresses
            }
          ]
        }
      ]
      private_dns_zone_group = length(v.private_dns_zone_group) > 0 ? {
        id                   = v.private_dns_zone_group[0].id
        name                 = v.private_dns_zone_group[0].name
        private_dns_zone_ids = v.private_dns_zone_group[0].private_dns_zone_ids
      } : null
    }
  } : {}
}

output "private_endpoints_by_subresource" {
  description = "Private endpoints grouped by subresource type (blob, file, table, queue, web, dfs)"
  value = length(azurerm_private_endpoint.private_endpoint) > 0 ? {
    for subresource in distinct(flatten([
      for pe in azurerm_private_endpoint.private_endpoint : pe.private_service_connection[0].subresource_names
      ])) : subresource => {
      for k, v in azurerm_private_endpoint.private_endpoint : k => {
        id                 = v.id
        name               = v.name
        private_ip_address = v.private_service_connection[0].private_ip_address
        fqdn               = try(v.custom_dns_configs[0].fqdn, null)
        network_interface = {
          id   = v.network_interface[0].id
          name = v.network_interface[0].name
        }
      } if contains(v.private_service_connection[0].subresource_names, subresource)
    }
  } : {}
}

output "lifecycle_management_policy_id" {
  description = "The ID of the Storage Account Management Policy"
  value       = try(azurerm_storage_management_policy.storage_management_policy[0].id, null)
}

output "containers" {
  description = "Map of created storage containers with all available attributes"
  value = {
    for k, v in azurerm_storage_container.storage_container : k => {
      id                       = v.id
      name                     = v.name
      resource_manager_id      = v.resource_manager_id
      has_immutability_policy  = v.has_immutability_policy
      has_legal_hold           = v.has_legal_hold
      default_encryption_scope = v.default_encryption_scope
      metadata                 = v.metadata
    }
  }
}

output "queues" {
  description = "Map of created storage queues"
  value = {
    for k, v in azurerm_storage_queue.storage_queue : k => {
      id                  = v.id
      name                = v.name
      resource_manager_id = v.resource_manager_id
    }
  }
}

output "tables" {
  description = "Map of created storage tables"
  value = {
    for k, v in azurerm_storage_table.storage_table : k => {
      id                  = v.id
      name                = v.name
      resource_manager_id = v.resource_manager_id
    }
  }
}

output "file_shares" {
  description = "Map of created file shares"
  value = {
    for k, v in azurerm_storage_share.storage_share : k => {
      id                  = v.id
      name                = v.name
      resource_manager_id = v.resource_manager_id
      url                 = v.url
    }
  }
}

output "queue_properties_id" {
  description = "The ID of the Storage Account Queue Properties"
  value       = one(azurerm_storage_account_queue_properties.queue_properties[*].id)
}

output "static_website" {
  description = "Static website properties"
  value = try(var.static_website.enabled, false) && try(var.static_website.index_document, null) != null ? {
    enabled            = true
    index_document     = azurerm_storage_account_static_website.static_website[0].index_document
    error_404_document = azurerm_storage_account_static_website.static_website[0].error_404_document
    primary_endpoint   = try(azurerm_storage_account.storage_account.primary_web_endpoint, null)
    secondary_endpoint = try(azurerm_storage_account.storage_account.secondary_web_endpoint, null)
    primary_host       = try(azurerm_storage_account.storage_account.primary_web_host, null)
    secondary_host     = try(azurerm_storage_account.storage_account.secondary_web_host, null)
  } : null
}

output "static_website_id" {
  description = "The ID of the Storage Account Static Website configuration"
  value       = try(azurerm_storage_account_static_website.static_website[0].id, null)
}

output "diagnostic_settings" {
  description = "Map of diagnostic settings created for the storage account"
  value = {
    storage_account = var.diagnostic_settings.enabled ? {
      id   = azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting[0].id
      name = azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting[0].name
    } : null
    blob_service = var.diagnostic_settings.enabled && var.account_kind != "FileStorage" ? {
      id   = azurerm_monitor_diagnostic_setting.blob_diagnostic_setting[0].id
      name = azurerm_monitor_diagnostic_setting.blob_diagnostic_setting[0].name
    } : null
  }
}

