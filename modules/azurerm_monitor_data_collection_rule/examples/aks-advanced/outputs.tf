output "kubernetes_cluster_id" {
  description = "The AKS cluster ID."
  value       = module.kubernetes_cluster.id
}

output "monitor_data_collection_rule_id" {
  description = "The Data Collection Rule ID."
  value       = module.monitor_data_collection_rule.id
}

output "monitor_data_collection_endpoint_id" {
  description = "The Data Collection Endpoint ID."
  value       = module.monitor_data_collection_endpoint.id
}

output "monitor_data_collection_rule_association_id" {
  description = "The Data Collection Rule association ID."
  value       = module.monitor_data_collection_rule.associations["${var.cluster_name}-dcr-assoc"].id
}
