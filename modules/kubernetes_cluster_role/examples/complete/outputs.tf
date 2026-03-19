output "kubernetes_cluster_role_id" {
  description = "The ID of the created Kubernetes Cluster Role"
  value       = module.kubernetes_cluster_role.id
}

output "kubernetes_cluster_role_name" {
  description = "The name of the created Kubernetes Cluster Role"
  value       = module.kubernetes_cluster_role.name
}
