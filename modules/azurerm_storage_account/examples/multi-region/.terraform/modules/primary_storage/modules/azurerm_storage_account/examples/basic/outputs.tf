output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.storage_account.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = module.storage_account.primary_blob_endpoint
}

output "primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = module.storage_account.primary_connection_string
  sensitive   = true
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = module.storage_account.primary_access_key
  sensitive   = true
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "location" {
  description = "The Azure location where resources are deployed"
  value       = azurerm_resource_group.example.location
}