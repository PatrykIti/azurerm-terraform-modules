output "monitor_data_collection_endpoint_id" {
  description = "The ID of the created Monitor Data Collection Endpoint"
  value       = module.monitor_data_collection_endpoint.id
}

output "monitor_data_collection_endpoint_name" {
  description = "The name of the created Monitor Data Collection Endpoint"
  value       = module.monitor_data_collection_endpoint.name
}

output "resource_group_name" {
  description = "The name of the resource group used for the Data Collection Endpoint"
  value       = azurerm_resource_group.example.name
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Data Collection Endpoint"
  value       = module.monitor_data_collection_endpoint.public_network_access_enabled
}
