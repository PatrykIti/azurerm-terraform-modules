output "monitor_data_collection_rule_id" {
  description = "The Data Collection Rule ID."
  value       = module.monitor_data_collection_rule.id
}

output "monitor_data_collection_endpoint_id" {
  description = "The Data Collection Endpoint ID."
  value       = module.monitor_data_collection_endpoint.id
}
