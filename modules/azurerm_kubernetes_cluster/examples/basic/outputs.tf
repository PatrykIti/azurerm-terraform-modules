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
  value       = module.kubernetes_cluster.kube_config[0].host
  sensitive   = true
}

output "client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster"
  value       = module.kubernetes_cluster.kube_config[0].client_certificate
  sensitive   = true
}

output "connect_command" {
  description = "Command to connect to the cluster using kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.example.name} --name ${module.kubernetes_cluster.name}"
}
