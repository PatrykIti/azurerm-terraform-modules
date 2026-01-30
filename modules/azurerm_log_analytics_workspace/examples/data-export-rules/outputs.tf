output "data_export_rules" {
  description = "Data export rules created by the module."
  value       = module.log_analytics_workspace.data_export_rules
}
