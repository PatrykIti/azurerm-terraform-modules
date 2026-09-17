output "kubernetes_cluster_id" {
  description = "The ID of the created Kubernetes Cluster"
  value       = module.kubernetes_cluster.id
}

output "kubernetes_cluster_name" {
  description = "The name of the created Kubernetes Cluster"
  value       = module.kubernetes_cluster.name
}

output "kubernetes_cluster_fqdn" {
  description = "The FQDN of the Azure Kubernetes Service"
  value       = module.kubernetes_cluster.fqdn
}

output "kubernetes_cluster_endpoint" {
  description = "The endpoint for the Kubernetes API server"
  value       = module.kubernetes_cluster.kube_config != null ? module.kubernetes_cluster.kube_config.host : null
  sensitive   = true
}

output "node_pools" {
  description = "List of additional node pools created"
  value       = module.kubernetes_cluster.node_pools
}

output "connect_command" {
  description = "Command to connect to the cluster using kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.example.name} --name ${module.kubernetes_cluster.name}"
}