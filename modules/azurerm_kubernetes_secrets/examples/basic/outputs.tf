output "kubernetes_cluster_name" {
  description = "AKS cluster name"
  value       = module.kubernetes_cluster.name
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.example.name
}

output "kubernetes_secret_name" {
  description = "Kubernetes Secret name created by the module"
  value       = module.kubernetes_secrets.kubernetes_secret_name
}
