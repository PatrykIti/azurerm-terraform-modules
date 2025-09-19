# Storage Account Basic Information
output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.storage_account.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.storage_account.resource_group_name
}

output "location" {
  description = "The Azure location of the storage account"
  value       = module.storage_account.location
}

# Storage Account Configuration
output "account_tier" {
  description = "The tier of the storage account"
  value       = module.storage_account.account_tier
}

output "account_replication_type" {
  description = "The replication type of the storage account"
  value       = module.storage_account.account_replication_type
}

output "account_kind" {
  description = "The kind of the storage account"
  value       = module.storage_account.account_kind
}

output "access_tier" {
  description = "The access tier of the storage account"
  value       = module.storage_account.access_tier
}

# Locations
output "primary_location" {
  description = "The primary location of the storage account"
  value       = module.storage_account.primary_location
}

output "secondary_location" {
  description = "The secondary location of the storage account"
  value       = module.storage_account.secondary_location
}

# Blob Service Endpoints
output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = module.storage_account.primary_blob_endpoint
}

output "primary_blob_host" {
  description = "The primary blob host"
  value       = module.storage_account.primary_blob_host
}

output "secondary_blob_endpoint" {
  description = "The secondary blob endpoint"
  value       = module.storage_account.secondary_blob_endpoint
}

output "secondary_blob_host" {
  description = "The secondary blob host"
  value       = module.storage_account.secondary_blob_host
}

output "primary_blob_internet_endpoint" {
  description = "The internet routing endpoint URL for blob storage in the primary location"
  value       = module.storage_account.primary_blob_internet_endpoint
}

output "primary_blob_internet_host" {
  description = "The internet routing hostname for blob storage in the primary location"
  value       = module.storage_account.primary_blob_internet_host
}

output "primary_blob_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for blob storage in the primary location"
  value       = module.storage_account.primary_blob_microsoft_endpoint
}

output "primary_blob_microsoft_host" {
  description = "The microsoft routing hostname for blob storage in the primary location"
  value       = module.storage_account.primary_blob_microsoft_host
}

output "secondary_blob_internet_endpoint" {
  description = "The internet routing endpoint URL for blob storage in the secondary location"
  value       = module.storage_account.secondary_blob_internet_endpoint
}

output "secondary_blob_internet_host" {
  description = "The internet routing hostname for blob storage in the secondary location"
  value       = module.storage_account.secondary_blob_internet_host
}

output "secondary_blob_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for blob storage in the secondary location"
  value       = module.storage_account.secondary_blob_microsoft_endpoint
}

output "secondary_blob_microsoft_host" {
  description = "The microsoft routing hostname for blob storage in the secondary location"
  value       = module.storage_account.secondary_blob_microsoft_host
}

# Queue Service Endpoints
output "primary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the primary location"
  value       = module.storage_account.primary_queue_endpoint
}

output "primary_queue_host" {
  description = "The hostname for queue storage in the primary location"
  value       = module.storage_account.primary_queue_host
}

output "secondary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the secondary location"
  value       = module.storage_account.secondary_queue_endpoint
}

output "secondary_queue_host" {
  description = "The hostname for queue storage in the secondary location"
  value       = module.storage_account.secondary_queue_host
}

# Table Service Endpoints
output "primary_table_endpoint" {
  description = "The endpoint URL for table storage in the primary location"
  value       = module.storage_account.primary_table_endpoint
}

output "primary_table_host" {
  description = "The hostname for table storage in the primary location"
  value       = module.storage_account.primary_table_host
}

output "secondary_table_endpoint" {
  description = "The endpoint URL for table storage in the secondary location"
  value       = module.storage_account.secondary_table_endpoint
}

output "secondary_table_host" {
  description = "The hostname for table storage in the secondary location"
  value       = module.storage_account.secondary_table_host
}

# File Service Endpoints
output "primary_file_endpoint" {
  description = "The endpoint URL for file storage in the primary location"
  value       = module.storage_account.primary_file_endpoint
}

output "primary_file_host" {
  description = "The hostname for file storage in the primary location"
  value       = module.storage_account.primary_file_host
}

output "primary_file_internet_endpoint" {
  description = "The internet routing endpoint URL for file storage in the primary location"
  value       = module.storage_account.primary_file_internet_endpoint
}

output "primary_file_internet_host" {
  description = "The internet routing hostname for file storage in the primary location"
  value       = module.storage_account.primary_file_internet_host
}

output "primary_file_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for file storage in the primary location"
  value       = module.storage_account.primary_file_microsoft_endpoint
}

output "primary_file_microsoft_host" {
  description = "The microsoft routing hostname for file storage in the primary location"
  value       = module.storage_account.primary_file_microsoft_host
}

output "secondary_file_endpoint" {
  description = "The endpoint URL for file storage in the secondary location"
  value       = module.storage_account.secondary_file_endpoint
}

output "secondary_file_host" {
  description = "The hostname for file storage in the secondary location"
  value       = module.storage_account.secondary_file_host
}

output "secondary_file_internet_endpoint" {
  description = "The internet routing endpoint URL for file storage in the secondary location"
  value       = module.storage_account.secondary_file_internet_endpoint
}

output "secondary_file_internet_host" {
  description = "The internet routing hostname for file storage in the secondary location"
  value       = module.storage_account.secondary_file_internet_host
}

output "secondary_file_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for file storage in the secondary location"
  value       = module.storage_account.secondary_file_microsoft_endpoint
}

output "secondary_file_microsoft_host" {
  description = "The microsoft routing hostname for file storage in the secondary location"
  value       = module.storage_account.secondary_file_microsoft_host
}

# DFS (Data Lake) Endpoints
output "primary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the primary location"
  value       = module.storage_account.primary_dfs_endpoint
}

output "primary_dfs_host" {
  description = "The hostname for DFS storage in the primary location"
  value       = module.storage_account.primary_dfs_host
}

output "primary_dfs_internet_endpoint" {
  description = "The internet routing endpoint URL for DFS storage in the primary location"
  value       = module.storage_account.primary_dfs_internet_endpoint
}

output "primary_dfs_internet_host" {
  description = "The internet routing hostname for DFS storage in the primary location"
  value       = module.storage_account.primary_dfs_internet_host
}

output "primary_dfs_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for DFS storage in the primary location"
  value       = module.storage_account.primary_dfs_microsoft_endpoint
}

output "primary_dfs_microsoft_host" {
  description = "The microsoft routing hostname for DFS storage in the primary location"
  value       = module.storage_account.primary_dfs_microsoft_host
}

output "secondary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the secondary location"
  value       = module.storage_account.secondary_dfs_endpoint
}

output "secondary_dfs_host" {
  description = "The hostname for DFS storage in the secondary location"
  value       = module.storage_account.secondary_dfs_host
}

output "secondary_dfs_internet_endpoint" {
  description = "The internet routing endpoint URL for DFS storage in the secondary location"
  value       = module.storage_account.secondary_dfs_internet_endpoint
}

output "secondary_dfs_internet_host" {
  description = "The internet routing hostname for DFS storage in the secondary location"
  value       = module.storage_account.secondary_dfs_internet_host
}

output "secondary_dfs_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for DFS storage in the secondary location"
  value       = module.storage_account.secondary_dfs_microsoft_endpoint
}

output "secondary_dfs_microsoft_host" {
  description = "The microsoft routing hostname for DFS storage in the secondary location"
  value       = module.storage_account.secondary_dfs_microsoft_host
}

# Web (Static Website) Endpoints
output "primary_web_endpoint" {
  description = "The endpoint URL for web storage in the primary location"
  value       = module.storage_account.primary_web_endpoint
}

output "primary_web_host" {
  description = "The hostname for web storage in the primary location"
  value       = module.storage_account.primary_web_host
}

output "primary_web_internet_endpoint" {
  description = "The internet routing endpoint URL for web storage in the primary location"
  value       = module.storage_account.primary_web_internet_endpoint
}

output "primary_web_internet_host" {
  description = "The internet routing hostname for web storage in the primary location"
  value       = module.storage_account.primary_web_internet_host
}

output "primary_web_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for web storage in the primary location"
  value       = module.storage_account.primary_web_microsoft_endpoint
}

output "primary_web_microsoft_host" {
  description = "The microsoft routing hostname for web storage in the primary location"
  value       = module.storage_account.primary_web_microsoft_host
}

output "secondary_web_endpoint" {
  description = "The endpoint URL for web storage in the secondary location"
  value       = module.storage_account.secondary_web_endpoint
}

output "secondary_web_host" {
  description = "The hostname for web storage in the secondary location"
  value       = module.storage_account.secondary_web_host
}

output "secondary_web_internet_endpoint" {
  description = "The internet routing endpoint URL for web storage in the secondary location"
  value       = module.storage_account.secondary_web_internet_endpoint
}

output "secondary_web_internet_host" {
  description = "The internet routing hostname for web storage in the secondary location"
  value       = module.storage_account.secondary_web_internet_host
}

output "secondary_web_microsoft_endpoint" {
  description = "The microsoft routing endpoint URL for web storage in the secondary location"
  value       = module.storage_account.secondary_web_microsoft_endpoint
}

output "secondary_web_microsoft_host" {
  description = "The microsoft routing hostname for web storage in the secondary location"
  value       = module.storage_account.secondary_web_microsoft_host
}

# Connection Strings and Access Keys (Sensitive)
output "primary_connection_string" {
  description = "The primary connection string"
  value       = module.storage_account.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The secondary connection string"
  value       = module.storage_account.secondary_connection_string
  sensitive   = true
}

output "primary_blob_connection_string" {
  description = "The primary blob connection string"
  value       = module.storage_account.primary_blob_connection_string
  sensitive   = true
}

output "secondary_blob_connection_string" {
  description = "The secondary blob connection string"
  value       = module.storage_account.secondary_blob_connection_string
  sensitive   = true
}

output "primary_access_key" {
  description = "The primary access key"
  value       = module.storage_account.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key"
  value       = module.storage_account.secondary_access_key
  sensitive   = true
}

# Security and Feature Settings
output "https_traffic_only_enabled" {
  description = "Is HTTPS traffic only enabled"
  value       = module.storage_account.https_traffic_only_enabled
}

output "min_tls_version" {
  description = "The minimum TLS version"
  value       = module.storage_account.min_tls_version
}

output "infrastructure_encryption_enabled" {
  description = "Is infrastructure encryption enabled"
  value       = module.storage_account.infrastructure_encryption_enabled
}

output "allow_nested_items_to_be_public" {
  description = "Are nested items allowed to be public"
  value       = module.storage_account.allow_nested_items_to_be_public
}

output "cross_tenant_replication_enabled" {
  description = "Is cross tenant replication enabled"
  value       = module.storage_account.cross_tenant_replication_enabled
}

output "shared_access_key_enabled" {
  description = "Are shared access keys enabled"
  value       = module.storage_account.shared_access_key_enabled
}

output "queue_encryption_key_type" {
  description = "The encryption type of the queue service"
  value       = module.storage_account.queue_encryption_key_type
}

output "table_encryption_key_type" {
  description = "The encryption type of the table service"
  value       = module.storage_account.table_encryption_key_type
}

# Data Lake and Protocol Support
output "is_hns_enabled" {
  description = "Is Hierarchical Namespace enabled (Data Lake Gen2)"
  value       = module.storage_account.is_hns_enabled
}

output "nfsv3_enabled" {
  description = "Is NFSv3 protocol enabled"
  value       = module.storage_account.nfsv3_enabled
}

output "large_file_share_enabled" {
  description = "Are large file shares enabled"
  value       = module.storage_account.large_file_share_enabled
}

# Identity
output "identity" {
  description = "The identity configuration of the storage account"
  value       = module.storage_account.identity
}

# Private Endpoints (from separate resources)
output "private_endpoints" {
  description = "Map of private endpoints"
  value = {
    blob = {
      id   = azurerm_private_endpoint.blob.id
      name = azurerm_private_endpoint.blob.name
    }
    file = {
      id   = azurerm_private_endpoint.file.id
      name = azurerm_private_endpoint.file.name
    }
    queue = {
      id   = azurerm_private_endpoint.queue.id
      name = azurerm_private_endpoint.queue.name
    }
    table = {
      id   = azurerm_private_endpoint.table.id
      name = azurerm_private_endpoint.table.name
    }
  }
}

# Storage Resources
output "containers" {
  description = "Map of created storage containers"
  value       = module.storage_account.containers
}

output "queues" {
  description = "Map of created storage queues"
  value       = module.storage_account.queues
}

output "tables" {
  description = "Map of created storage tables"
  value       = module.storage_account.tables
}

output "file_shares" {
  description = "Map of created file shares"
  value       = module.storage_account.file_shares
}

# Management and Configuration
output "lifecycle_management_policy_id" {
  description = "The ID of the Storage Account Management Policy"
  value       = module.storage_account.lifecycle_management_policy_id
}

output "queue_properties_id" {
  description = "The ID of the Storage Account Queue Properties"
  value       = module.storage_account.queue_properties_id
}

output "static_website" {
  description = "Static website properties"
  value       = module.storage_account.static_website
}

output "static_website_id" {
  description = "The ID of the Storage Account Static Website configuration"
  value       = module.storage_account.static_website_id
}

# Diagnostic Settings (from separate resources)
output "diagnostic_settings" {
  description = "Map of diagnostic settings created"
  value = {
    storage_account = {
      id   = azurerm_monitor_diagnostic_setting.storage_account.id
      name = azurerm_monitor_diagnostic_setting.storage_account.name
    }
    blob_service = {
      id   = azurerm_monitor_diagnostic_setting.blob_service.id
      name = azurerm_monitor_diagnostic_setting.blob_service.name
    }
  }
}

output "tags" {
  description = "Tags assigned to the storage account"
  value       = module.storage_account.tags
}

# Example Infrastructure Resources
output "key_vault_id" {
  description = "The ID of the Key Vault used for CMK"
  value       = azurerm_key_vault.example.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.id
}

output "virtual_network_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.example.id
}

output "private_endpoint_subnet_id" {
  description = "The ID of the subnet for private endpoints"
  value       = azurerm_subnet.private_endpoints.id
}