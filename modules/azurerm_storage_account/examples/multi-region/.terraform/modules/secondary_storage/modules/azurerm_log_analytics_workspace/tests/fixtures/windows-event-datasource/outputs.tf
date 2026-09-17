output "windows_event_datasources" {
  description = "Windows event data sources created by the module."
  value       = module.log_analytics_workspace.windows_event_datasources
}
