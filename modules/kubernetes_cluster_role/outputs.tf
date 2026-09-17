output "id" {
  description = "The Terraform ID of the ClusterRole."
  value       = try(kubernetes_cluster_role_v1.cluster_role.id, null)
}

output "name" {
  description = "The ClusterRole name."
  value       = try(kubernetes_cluster_role_v1.cluster_role.metadata[0].name, null)
}

output "rules" {
  description = "The rendered ClusterRole rules."
  value       = try(kubernetes_cluster_role_v1.cluster_role.rule, [])
}

output "aggregation_rule" {
  description = "The rendered aggregation rule."
  value       = try(kubernetes_cluster_role_v1.cluster_role.aggregation_rule[0], null)
}
