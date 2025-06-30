output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.storage_account.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "primary_location" {
  description = "The primary location of the storage account"
  value       = module.storage_account.primary_location
}

output "secondary_location" {
  description = "The secondary location of the storage account"
  value       = module.storage_account.secondary_location
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = module.storage_account.primary_blob_endpoint
}

output "primary_blob_host" {
  description = "The primary blob host"
  value       = module.storage_account.primary_blob_host
}

output "primary_connection_string" {
  description = "The primary connection string"
  value       = module.storage_account.primary_connection_string
  sensitive   = true
}

output "identity" {
  description = "The identity configuration of the storage account"
  value       = module.storage_account.identity
}

output "private_endpoint_ids" {
  description = "Map of private endpoint IDs"
  value       = module.storage_account.private_endpoint_ids
}

output "key_vault_id" {
  description = "The ID of the Key Vault used for CMK"
  value       = azurerm_key_vault.example.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.id
}