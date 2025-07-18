output "id" {
  description = "The ID of the created Network Security Group."
  value       = module.network_security_group.id
}

output "name" {
  description = "The name of the created Network Security Group."
  value       = module.network_security_group.name
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.test.name
}

output "flow_log_id" {
  description = "The ID of the NSG Flow Log."
  value       = module.network_security_group.flow_log_id
}
