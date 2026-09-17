output "kubernetes_cluster_id" {
  description = "The ID of the created Kubernetes Cluster."
  value       = module.kubernetes_cluster.id
}

output "kubernetes_cluster_name" {
  description = "The name of the created Kubernetes Cluster."
  value       = module.kubernetes_cluster.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the cluster was created."
  value       = azurerm_resource_group.test.name
}