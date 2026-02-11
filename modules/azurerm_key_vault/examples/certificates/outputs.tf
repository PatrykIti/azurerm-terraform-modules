output "key_vault_id" {
  description = "The ID of the created Key Vault"
  value       = module.key_vault.id
}

output "key_vault_name" {
  description = "The name of the created Key Vault"
  value       = module.key_vault.name
}
