output "variable_group_id" {
  description = "Variable group ID created in this example."
  value       = module.azuredevops_variable_groups.variable_group_id
}

output "variable_group_name" {
  description = "Variable group name created in this example."
  value       = module.azuredevops_variable_groups.variable_group_name
}
