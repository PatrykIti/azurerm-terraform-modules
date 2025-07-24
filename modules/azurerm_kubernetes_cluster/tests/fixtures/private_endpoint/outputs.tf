output "kubernetes_cluster_id" {
  description = "The ID of the created Kubernetes Cluster"
  value       = module.kubernetes_cluster.id
}

output "kubernetes_cluster_name" {
  description = "The name of the created Kubernetes Cluster"
  value       = module.kubernetes_cluster.name
}

output "private_fqdn" {
  description = "The FQDN for the private Kubernetes Cluster"
  value       = module.kubernetes_cluster.private_fqdn
}

output "private_endpoints" {
  description = "Information about the created private endpoints"
  value       = module.kubernetes_cluster.private_endpoints
}

output "private_endpoints_count" {
  description = "Number of private endpoints created"
  value       = length(module.kubernetes_cluster.private_endpoints)
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.test.name
}

output "private_endpoint_name" {
  description = "The name of the first private endpoint"
  value       = length(module.kubernetes_cluster.private_endpoints) > 0 ? module.kubernetes_cluster.private_endpoints[0].name : ""
}

