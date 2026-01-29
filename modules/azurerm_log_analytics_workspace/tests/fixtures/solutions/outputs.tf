output "solutions" {
  description = "Log Analytics solutions created by the module."
  value       = module.log_analytics_workspace.solutions
}
