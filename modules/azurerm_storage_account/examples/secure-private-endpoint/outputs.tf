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

output "private_endpoint_subnet_id" {
  description = "The ID of the subnet used for private endpoints"
  value       = azurerm_subnet.private_endpoints.id
}

output "private_dns_zones" {
  description = "The private DNS zones created for storage services"
  value = {
    blob  = azurerm_private_dns_zone.blob.name
    file  = azurerm_private_dns_zone.file.name
    queue = azurerm_private_dns_zone.queue.name
    table = azurerm_private_dns_zone.table.name
  }
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
    https_only                      = true
    min_tls_version                 = "TLS1_2"
    allow_nested_items_to_be_public = false
    shared_key_enabled              = true # Required for Terraform management
    infrastructure_encryption       = true
    network_default_action          = "Deny"
    private_endpoints_enabled       = true
    customer_managed_key            = true
    diagnostic_logging              = true
    versioning_enabled              = true
    change_feed_enabled             = true
  }
}