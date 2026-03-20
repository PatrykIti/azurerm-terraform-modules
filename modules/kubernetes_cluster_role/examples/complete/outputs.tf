output "cluster_role_name" {
  description = "Created ClusterRole name."
  value       = module.kubernetes_cluster_role.name
}

output "cluster_role_rule_count" {
  description = "Number of rendered rules."
  value       = length(module.kubernetes_cluster_role.rules)
}
