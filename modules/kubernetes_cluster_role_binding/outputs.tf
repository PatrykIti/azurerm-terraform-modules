output "id" {
  description = "The Terraform ID of the ClusterRoleBinding."
  value       = try(kubernetes_cluster_role_binding_v1.cluster_role_binding.id, null)
}

output "name" {
  description = "The ClusterRoleBinding name."
  value       = try(kubernetes_cluster_role_binding_v1.cluster_role_binding.metadata[0].name, null)
}

output "role_ref" {
  description = "The referenced cluster role."
  value       = try(kubernetes_cluster_role_binding_v1.cluster_role_binding.role_ref[0], null)
}

output "subjects" {
  description = "The subjects bound by the ClusterRoleBinding."
  value       = try(kubernetes_cluster_role_binding_v1.cluster_role_binding.subject, [])
}
