output "kubernetes_cluster_role_binding_id" {
  description = "The ID of the created Kubernetes Cluster Role Binding"
  value       = module.kubernetes_cluster_role_binding.id
}

output "kubernetes_cluster_role_binding_name" {
  description = "The name of the created Kubernetes Cluster Role Binding"
  value       = module.kubernetes_cluster_role_binding.name
}
