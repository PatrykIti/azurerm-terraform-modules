output "cluster_role_name" {
  description = "Created ClusterRole name."
  value       = module.kubernetes_cluster_role.name
}
