output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.storage_account.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint (accessible only via private endpoint)"
  value       = module.storage_account.primary_blob_endpoint
}

output "identity_principal_id" {
  description = "The principal ID of the storage account's system-assigned identity"
  value       = module.storage_account.identity.principal_id
}

output "private_endpoint_ids" {
  description = "Map of private endpoint IDs"
  value       = module.storage_account.private_endpoint_ids
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.example.vault_uri
}

output "encryption_key_id" {
  description = "The ID of the encryption key"
  value       = azurerm_key_vault_key.storage.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for security monitoring"
  value       = azurerm_log_analytics_workspace.example.id
}

output "security_alert_id" {
  description = "The ID of the authentication failure alert"
  value       = azurerm_monitor_metric_alert.storage_auth_failures.id
}