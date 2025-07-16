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

output "private_dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = azurerm_private_dns_zone.aks.id
}

