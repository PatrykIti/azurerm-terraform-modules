output "postgresql_flexible_server_id" {
  description = "The PostgreSQL Flexible Server ID."
  value       = module.postgresql_flexible_server.id
}

output "key_vault_id" {
  description = "Key Vault ID used for CMK."
  value       = azurerm_key_vault.example.id
}
