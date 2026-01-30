output "kubernetes_cluster_name" {
  description = "AKS cluster name"
  value       = module.kubernetes_cluster.name
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.example.name
}

output "secret_store_name" {
  description = "SecretStore name"
  value       = module.kubernetes_secrets.secret_store_name
}

output "external_secret_names" {
  description = "ExternalSecret names"
  value       = module.kubernetes_secrets.external_secret_names
}
