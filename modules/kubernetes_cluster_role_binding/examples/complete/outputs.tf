output "cluster_role_binding_id" {
  description = "The Terraform ID of the created ClusterRoleBinding."
  value       = module.kubernetes_cluster_role_binding.id
}

output "subjects" {
  description = "Subjects bound by the ClusterRoleBinding."
  value       = module.kubernetes_cluster_role_binding.subjects
}
