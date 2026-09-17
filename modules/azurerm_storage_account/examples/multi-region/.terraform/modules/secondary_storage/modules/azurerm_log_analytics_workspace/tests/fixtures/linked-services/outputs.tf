output "linked_services" {
  description = "Linked services created by the module."
  value       = module.log_analytics_workspace.linked_services
}
