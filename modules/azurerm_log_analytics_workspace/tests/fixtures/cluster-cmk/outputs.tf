output "cluster_customer_managed_keys" {
  description = "Cluster CMK resources created by the module."
  value       = module.log_analytics_workspace.cluster_customer_managed_keys
}
