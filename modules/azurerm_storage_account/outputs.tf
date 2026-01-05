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

output "primary_blob_internet_endpoint" {
  description = "The internet routing endpoint URL for blob storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_blob_internet_endpoint, null)
}

output "primary_blob_internet_host" {
  description = "The internet routing hostname with port if applicable for blob storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_blob_internet_host, null)
}

output "primary_blob_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for blob storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_blob_microsoft_endpoint, null)
}

output "primary_blob_microsoft_host" {
  description = "The microsoft routing hostname with port if applicable for blob storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_blob_microsoft_host, null)
}

output "secondary_blob_internet_endpoint" {
  description = "The internet routing endpoint URL for blob storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_blob_internet_endpoint, null)
}

output "secondary_blob_internet_host" {
  description = "The internet routing hostname with port if applicable for blob storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_blob_internet_host, null)
}

output "secondary_blob_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for blob storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_blob_microsoft_endpoint, null)
}

output "secondary_blob_microsoft_host" {
  description = "The microsoft routing hostname with port if applicable for blob storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_blob_microsoft_host, null)
}

output "primary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_queue_endpoint, null)
}

output "primary_queue_host" {
  description = "The hostname with port if applicable for queue storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_queue_host, null)
}

output "secondary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_queue_endpoint, null)
}

output "secondary_queue_host" {
  description = "The hostname with port if applicable for queue storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_queue_host, null)
}

output "primary_table_endpoint" {
  description = "The endpoint URL for table storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_table_endpoint, null)
}

output "primary_table_host" {
  description = "The hostname with port if applicable for table storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_table_host, null)
}

output "secondary_table_endpoint" {
  description = "The endpoint URL for table storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_table_endpoint, null)
}

output "secondary_table_host" {
  description = "The hostname with port if applicable for table storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_table_host, null)
}

output "primary_file_endpoint" {
  description = "The endpoint URL for file storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_file_endpoint, null)
}

output "primary_file_host" {
  description = "The hostname with port if applicable for file storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_file_host, null)
}

output "primary_file_internet_endpoint" {
  description = "The internet routing endpoint URL for file storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_file_internet_endpoint, null)
}

output "primary_file_internet_host" {
  description = "The internet routing hostname with port if applicable for file storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_file_internet_host, null)
}

output "primary_file_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for file storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_file_microsoft_endpoint, null)
}

output "primary_file_microsoft_host" {
  description = "The microsoft routing hostname with port if applicable for file storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_file_microsoft_host, null)
}

output "secondary_file_endpoint" {
  description = "The endpoint URL for file storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_file_endpoint, null)
}

output "secondary_file_host" {
  description = "The hostname with port if applicable for file storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_file_host, null)
}

output "secondary_file_internet_endpoint" {
  description = "The internet routing endpoint URL for file storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_file_internet_endpoint, null)
}

output "secondary_file_internet_host" {
  description = "The internet routing hostname with port if applicable for file storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_file_internet_host, null)
}

output "secondary_file_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for file storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_file_microsoft_endpoint, null)
}

output "secondary_file_microsoft_host" {
  description = "The microsoft routing hostname with port if applicable for file storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_file_microsoft_host, null)
}

output "primary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_dfs_endpoint, null)
}

output "primary_dfs_host" {
  description = "The hostname with port if applicable for DFS storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_dfs_host, null)
}

output "primary_dfs_internet_endpoint" {
  description = "The internet routing endpoint URL for DFS storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_dfs_internet_endpoint, null)
}

output "primary_dfs_internet_host" {
  description = "The internet routing hostname with port if applicable for DFS storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_dfs_internet_host, null)
}

output "primary_dfs_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for DFS storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_dfs_microsoft_endpoint, null)
}

output "primary_dfs_microsoft_host" {
  description = "The microsoft routing hostname with port if applicable for DFS storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_dfs_microsoft_host, null)
}

output "secondary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_dfs_endpoint, null)
}

output "secondary_dfs_host" {
  description = "The hostname with port if applicable for DFS storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_dfs_host, null)
}

output "secondary_dfs_internet_endpoint" {
  description = "The internet routing endpoint URL for DFS storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_dfs_internet_endpoint, null)
}

output "secondary_dfs_internet_host" {
  description = "The internet routing hostname with port if applicable for DFS storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_dfs_internet_host, null)
}

output "secondary_dfs_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for DFS storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_dfs_microsoft_endpoint, null)
}

output "secondary_dfs_microsoft_host" {
  description = "The microsoft routing hostname with port if applicable for DFS storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_dfs_microsoft_host, null)
}

output "primary_web_endpoint" {
  description = "The endpoint URL for web storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_web_endpoint, null)
}

output "primary_web_host" {
  description = "The hostname with port if applicable for web storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_web_host, null)
}

output "primary_web_internet_endpoint" {
  description = "The internet routing endpoint URL for web storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_web_internet_endpoint, null)
}

output "primary_web_internet_host" {
  description = "The internet routing hostname with port if applicable for web storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_web_internet_host, null)
}

output "primary_web_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for web storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_web_microsoft_endpoint, null)
}

output "primary_web_microsoft_host" {
  description = "The microsoft routing hostname with port if applicable for web storage in the primary location"
  value       = try(azurerm_storage_account.storage_account.primary_web_microsoft_host, null)
}

output "secondary_web_endpoint" {
  description = "The endpoint URL for web storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_web_endpoint, null)
}

output "secondary_web_host" {
  description = "The hostname with port if applicable for web storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_web_host, null)
}

output "secondary_web_internet_endpoint" {
  description = "The internet routing endpoint URL for web storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_web_internet_endpoint, null)
}

output "secondary_web_internet_host" {
  description = "The internet routing hostname with port if applicable for web storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_web_internet_host, null)
}

output "secondary_web_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for web storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_web_microsoft_endpoint, null)
}

output "secondary_web_microsoft_host" {
  description = "The microsoft routing hostname with port if applicable for web storage in the secondary location"
  value       = try(azurerm_storage_account.storage_account.secondary_web_microsoft_host, null)
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

output "diagnostic_settings_skipped" {
  description = "Diagnostic settings entries skipped because no categories were available after filtering."
  value       = local.diagnostic_settings_skipped
}


output "account_tier" {
  description = "The Tier of the storage account"
  value       = try(azurerm_storage_account.storage_account.account_tier, null)
}

output "account_replication_type" {
  description = "The replication type of the storage account"
  value       = try(azurerm_storage_account.storage_account.account_replication_type, null)
}

output "account_kind" {
  description = "The Kind of the storage account"
  value       = try(azurerm_storage_account.storage_account.account_kind, null)
}

output "access_tier" {
  description = "The access tier of the storage account"
  value       = try(azurerm_storage_account.storage_account.access_tier, null)
}

output "https_traffic_only_enabled" {
  description = "Is HTTPS traffic only enabled for the storage account"
  value       = try(azurerm_storage_account.storage_account.https_traffic_only_enabled, null)
}

output "min_tls_version" {
  description = "The minimum TLS version of the storage account"
  value       = try(azurerm_storage_account.storage_account.min_tls_version, null)
}

output "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled for the storage account"
  value       = try(azurerm_storage_account.storage_account.is_hns_enabled, null)
}

output "nfsv3_enabled" {
  description = "Is NFSv3 protocol enabled for the storage account"
  value       = try(azurerm_storage_account.storage_account.nfsv3_enabled, null)
}

output "large_file_share_enabled" {
  description = "Are Large File Shares enabled for the storage account"
  value       = try(azurerm_storage_account.storage_account.large_file_share_enabled, null)
}

output "infrastructure_encryption_enabled" {
  description = "Is infrastructure encryption enabled for the storage account"
  value       = try(azurerm_storage_account.storage_account.infrastructure_encryption_enabled, null)
}

output "allow_nested_items_to_be_public" {
  description = "Are nested items allowed to be public for the storage account"
  value       = try(azurerm_storage_account.storage_account.allow_nested_items_to_be_public, null)
}

output "cross_tenant_replication_enabled" {
  description = "Is cross tenant replication enabled for the storage account"
  value       = try(azurerm_storage_account.storage_account.cross_tenant_replication_enabled, null)
}

output "shared_access_key_enabled" {
  description = "Are shared access keys enabled for the storage account"
  value       = try(azurerm_storage_account.storage_account.shared_access_key_enabled, null)
}

output "queue_encryption_key_type" {
  description = "The encryption type of the queue service"
  value       = try(azurerm_storage_account.storage_account.queue_encryption_key_type, null)
}

output "table_encryption_key_type" {
  description = "The encryption type of the table service"
  value       = try(azurerm_storage_account.storage_account.table_encryption_key_type, null)
}

output "resource_group_name" {
  description = "The name of the resource group in which the storage account is created"
  value       = try(azurerm_storage_account.storage_account.resource_group_name, null)
}

output "location" {
  description = "The Azure location where the storage account exists"
  value       = try(azurerm_storage_account.storage_account.location, null)
}

output "tags" {
  description = "A map of tags assigned to the storage account"
  value       = try(azurerm_storage_account.storage_account.tags, null)
}

output "sftp_enabled" {
  description = "Is SFTP enabled for the storage account"
  value       = try(azurerm_storage_account.storage_account.sftp_enabled, null)
}