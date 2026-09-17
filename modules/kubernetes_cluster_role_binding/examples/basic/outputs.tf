output "cluster_role_binding_id" {
  description = "The Terraform ID of the created ClusterRoleBinding."
  value       = module.kubernetes_cluster_role_binding.id
}

output "cluster_role_binding_name" {
  description = "The created ClusterRoleBinding name."
  value       = module.kubernetes_cluster_role_binding.name
}
