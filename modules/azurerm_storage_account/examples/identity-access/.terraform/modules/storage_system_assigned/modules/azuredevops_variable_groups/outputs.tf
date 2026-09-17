output "variable_group_id" {
  description = "The ID of the Azure DevOps variable group."
  value       = try(azuredevops_variable_group.variable_group.id, null)
}

output "variable_group_name" {
  description = "The name of the Azure DevOps variable group."
  value       = try(azuredevops_variable_group.variable_group.name, null)
}
