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
  description = "Map of private endpoints created for the storage account"
  value = {
    for k, v in azurerm_private_endpoint.private_endpoint : k => {
      id                   = v.id
      name                 = v.name
      private_ip_addresses = [v.private_service_connection[0].private_ip_address]
      fqdn                 = try(v.custom_dns_configs[0].fqdn, null)
    }
  }
}

output "lifecycle_management_policy_id" {
  description = "The ID of the Storage Account Management Policy"
  value       = try(azurerm_storage_management_policy.storage_management_policy[0].id, null)
}

output "containers" {
  description = "Map of created storage containers"
  value = {
    for k, v in azurerm_storage_container.storage_container : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "queues" {
  description = "Map of created storage queues"
  value = {
    for k, v in azurerm_storage_queue.storage_queue : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "tables" {
  description = "Map of created storage tables"
  value = {
    for k, v in azurerm_storage_table.storage_table : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "file_shares" {
  description = "Map of created file shares"
  value = {
    for k, v in azurerm_storage_share.storage_share : k => {
      id   = v.id
      name = v.name
      url  = v.url
    }
  }
}

output "queue_properties_id" {
  description = "The ID of the Storage Account Queue Properties"
  value       = try(azurerm_storage_account_queue_properties.queue_properties[0].id, null)
}

output "static_website" {
  description = "Static website properties"
  value = try(var.static_website.enabled, false) && try(var.static_website.index_document, null) != null ? {
    enabled              = true
    index_document       = azurerm_storage_account_static_website.static_website[0].index_document
    error_404_document   = azurerm_storage_account_static_website.static_website[0].error_404_document
    primary_endpoint     = try(azurerm_storage_account.storage_account.primary_web_endpoint, null)
    secondary_endpoint   = try(azurerm_storage_account.storage_account.secondary_web_endpoint, null)
  } : null
}

