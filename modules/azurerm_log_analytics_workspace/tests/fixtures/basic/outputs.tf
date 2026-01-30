output "log_analytics_workspace_id" {
  description = "The Log Analytics Workspace ID."
  value       = module.log_analytics_workspace.id
}

output "log_analytics_workspace_name" {
  description = "The Log Analytics Workspace name."
  value       = module.log_analytics_workspace.name
}

output "resource_group_name" {
  description = "The resource group name."
  value       = azurerm_resource_group.example.name
}
