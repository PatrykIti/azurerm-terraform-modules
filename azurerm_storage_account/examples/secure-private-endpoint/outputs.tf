output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.secure_storage.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.secure_storage.name
}

output "private_endpoints" {
  description = "Details of the private endpoints"
  value       = module.secure_storage.private_endpoints
}

output "identity_principal_id" {
  description = "The principal ID of the storage account's managed identity"
  value       = module.secure_storage.identity.principal_id
}

output "key_vault_id" {
  description = "The ID of the Key Vault used for encryption"
  value       = azurerm_key_vault.example.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for diagnostics"
  value       = azurerm_log_analytics_workspace.example.id
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}

output "security_configuration" {
  description = "Summary of security settings applied"
  value = {
    https_only                = true
    min_tls_version           = "TLS1_2"
    public_access_disabled    = true
    shared_key_disabled       = true
    infrastructure_encryption = true
    advanced_threat_protection = true
    network_default_action    = "Deny"
    private_endpoints_enabled = true
    customer_managed_key      = true
    diagnostic_logging        = true
  }
}