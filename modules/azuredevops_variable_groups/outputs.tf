output "variable_group_id" {
  description = "ID of the variable group created by the module."
  value       = try(azuredevops_variable_group.variable_group.id, null)
}

output "variable_group_name" {
  description = "Name of the variable group created by the module."
  value       = try(azuredevops_variable_group.variable_group.name, null)
}
