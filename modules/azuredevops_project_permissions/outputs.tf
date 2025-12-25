output "variable_group_ids" {
  description = "Map of variable group IDs keyed by variable group key."
  value       = { for key, group in azuredevops_variable_group.variable_group : key => group.id }
}

output "variable_group_names" {
  description = "Map of variable group names keyed by variable group key."
  value       = { for key, group in azuredevops_variable_group.variable_group : key => group.name }
}
