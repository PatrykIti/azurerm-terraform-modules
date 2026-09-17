output "strategy" {
  description = "Selected strategy"
  value       = module.kubernetes_secrets.strategy
}

output "secret_store_name" {
  description = "SecretStore name"
  value       = module.kubernetes_secrets.secret_store_name
}

output "external_secret_names" {
  description = "ExternalSecret names"
  value       = module.kubernetes_secrets.external_secret_names
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.test.name
}

output "kube_config_raw" {
  description = "Kubeconfig for test automation"
  value       = module.kubernetes_cluster.kube_config_raw
  sensitive   = true
}
