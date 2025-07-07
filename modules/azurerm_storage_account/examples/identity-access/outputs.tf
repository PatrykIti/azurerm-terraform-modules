output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.storage_account.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "identity_principal_id" {
  description = "The Principal ID of the storage account's system-assigned managed identity"
  value       = module.storage_account.identity.principal_id
}

output "identity_tenant_id" {
  description = "The Tenant ID of the storage account's system-assigned managed identity"
  value       = module.storage_account.identity.tenant_id
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint URL"
  value       = module.storage_account.primary_blob_endpoint
}

output "test_container_name" {
  description = "The name of the test container"
  value       = azurerm_storage_container.test.name
}

output "current_user_object_id" {
  description = "The object ID of the current user (has Storage Blob Data Contributor role)"
  value       = data.azurerm_client_config.current.object_id
}

output "key_vault_id" {
  description = "The ID of the example Key Vault"
  value       = azurerm_key_vault.example.id
}

output "authentication_mode_note" {
  description = "Important note about authentication"
  value       = "This storage account has shared keys disabled. Use 'az storage blob list --account-name ${module.storage_account.name} --container-name ${azurerm_storage_container.test.name} --auth-mode login' to access blobs."
}