output "storage_account_id" {
  description = "The ID of the Data Lake Storage Gen2 account"
  value       = module.data_lake_storage.id
}

output "storage_account_name" {
  description = "The name of the Data Lake Storage Gen2 account"
  value       = module.data_lake_storage.name
}

output "primary_dfs_endpoint" {
  description = "The primary DFS endpoint for Data Lake Storage Gen2"
  value       = module.data_lake_storage.primary_dfs_endpoint
}

output "primary_dfs_host" {
  description = "The primary DFS host for Data Lake Storage Gen2"
  value       = module.data_lake_storage.primary_dfs_host
}

output "primary_dfs_internet_endpoint" {
  description = "The internet routing DFS endpoint for Data Lake Storage Gen2"
  value       = module.data_lake_storage.primary_dfs_internet_endpoint
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint (also supports DFS operations)"
  value       = module.data_lake_storage.primary_blob_endpoint
}

output "sftp_endpoint" {
  description = "The SFTP endpoint for the storage account"
  value       = "${module.data_lake_storage.name}.sftp.core.windows.net"
}

output "nfs_mount_point" {
  description = "The NFSv3 mount point for the storage account"
  value       = "${module.data_lake_storage.name}.blob.core.windows.net:/${module.data_lake_storage.name}"
}

output "bronze_filesystem_id" {
  description = "The ID of the bronze data lake filesystem"
  value       = azurerm_storage_data_lake_gen2_filesystem.bronze.id
}

output "silver_filesystem_id" {
  description = "The ID of the silver data lake filesystem"
  value       = azurerm_storage_data_lake_gen2_filesystem.silver.id
}

output "gold_filesystem_id" {
  description = "The ID of the gold data lake filesystem"
  value       = azurerm_storage_data_lake_gen2_filesystem.gold.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "virtual_network_name" {
  description = "The name of the virtual network for NFSv3 access"
  value       = azurerm_virtual_network.example.name
}

output "nfs_subnet_id" {
  description = "The ID of the subnet configured for NFSv3 access"
  value       = azurerm_subnet.nfs_clients.id
}

output "sftp_user_name" {
  description = "The name of the SFTP user"
  value       = azurerm_storage_account_local_user.sftp_user.name
}

output "data_lake_features" {
  description = "Summary of enabled Data Lake Gen2 features"
  value = {
    hierarchical_namespace = true
    sftp_enabled           = true
    nfsv3_enabled          = true
    local_users_enabled    = true
    filesystems = [
      azurerm_storage_data_lake_gen2_filesystem.bronze.name,
      azurerm_storage_data_lake_gen2_filesystem.silver.name,
      azurerm_storage_data_lake_gen2_filesystem.gold.name
    ]
  }
}