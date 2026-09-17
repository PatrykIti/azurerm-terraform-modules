output "monitor_private_link_scope_id" {
  description = "The ID of the created Monitor Private Link Scope."
  value       = module.monitor_private_link_scope.id
}

output "monitor_private_link_scope_name" {
  description = "The name of the created Monitor Private Link Scope."
  value       = module.monitor_private_link_scope.name
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.test.name
}
