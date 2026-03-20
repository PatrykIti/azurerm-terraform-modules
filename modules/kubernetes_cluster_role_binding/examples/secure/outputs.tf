output "cluster_role_binding_name" {
  description = "The created ClusterRoleBinding name."
  value       = module.kubernetes_cluster_role_binding.name
}

output "subjects" {
  description = "Subjects bound by the ClusterRoleBinding."
  value       = module.kubernetes_cluster_role_binding.subjects
}
