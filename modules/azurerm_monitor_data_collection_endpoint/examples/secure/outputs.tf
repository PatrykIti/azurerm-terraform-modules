output "monitor_data_collection_endpoint_id" {
  description = "The Data Collection Endpoint ID."
  value       = module.monitor_data_collection_endpoint.id
}

output "monitor_data_collection_endpoint_name" {
  description = "The Data Collection Endpoint name."
  value       = module.monitor_data_collection_endpoint.name
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = module.monitor_data_collection_endpoint.public_network_access_enabled
}
