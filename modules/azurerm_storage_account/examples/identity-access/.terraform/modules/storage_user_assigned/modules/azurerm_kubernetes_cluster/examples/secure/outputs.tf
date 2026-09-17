output "kubernetes_cluster_id" {
  description = "The ID of the created Kubernetes Cluster"
  value       = module.kubernetes_cluster.id
}

output "kubernetes_cluster_name" {
  description = "The name of the created Kubernetes Cluster"
  value       = module.kubernetes_cluster.name
}
