output "strategy" {
  description = "Selected strategy"
  value       = module.kubernetes_secrets.strategy
}

output "kubernetes_secret_name" {
  description = "Kubernetes Secret name"
  value       = module.kubernetes_secrets.kubernetes_secret_name
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.test.name
}
