output "key_vault_id" {
  description = "The ID of the created Key Vault"
  value       = module.key_vault.id
}

output "key_vault_name" {
  description = "The name of the created Key Vault"
  value       = module.key_vault.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "keys" {
  value = module.key_vault.keys
}

output "secrets" {
  value = module.key_vault.secrets
}

output "certificates" {
  value = module.key_vault.certificates
}

output "diagnostic_settings_skipped" {
  value = module.key_vault.diagnostic_settings_skipped
}
