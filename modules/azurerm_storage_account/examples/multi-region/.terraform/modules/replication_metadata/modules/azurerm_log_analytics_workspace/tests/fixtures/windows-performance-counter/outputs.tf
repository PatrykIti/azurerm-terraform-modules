output "windows_performance_counters" {
  description = "Windows performance counter data sources created by the module."
  value       = module.log_analytics_workspace.windows_performance_counters
}
