output "monitor_data_collection_rule_id" {
  description = "The ID of the created Monitor Data Collection Rule"
  value       = module.monitor_data_collection_rule.id
}

output "monitor_data_collection_rule_name" {
  description = "The name of the created Monitor Data Collection Rule"
  value       = module.monitor_data_collection_rule.name
}

output "resource_group_name" {
  description = "The name of the resource group used for the Data Collection Rule"
  value       = azurerm_resource_group.example.name
}
