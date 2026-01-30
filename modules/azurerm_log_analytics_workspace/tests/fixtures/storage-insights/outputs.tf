output "storage_insights" {
  description = "Storage insights created by the module."
  value       = module.log_analytics_workspace.storage_insights
}
