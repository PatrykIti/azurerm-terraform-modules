output "log_analytics_workspace_id" {
  description = "The Log Analytics Workspace ID."
  value       = module.log_analytics_workspace.id
}

output "log_analytics_workspace_name" {
  description = "The Log Analytics Workspace name."
  value       = module.log_analytics_workspace.name
}
