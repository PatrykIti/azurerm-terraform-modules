output "monitor_data_collection_endpoint_id" {
  description = "The Data Collection Endpoint ID."
  value       = module.monitor_data_collection_endpoint.id
}

output "monitor_data_collection_endpoint_name" {
  description = "The Data Collection Endpoint name."
  value       = module.monitor_data_collection_endpoint.name
}

output "configuration_access_endpoint" {
  description = "The Data Collection Endpoint configuration access endpoint."
  value       = module.monitor_data_collection_endpoint.configuration_access_endpoint
}
