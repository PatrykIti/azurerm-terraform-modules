output "variable_group_ids" {
  description = "Variable group IDs created in this fixture."
  value       = module.azuredevops_variable_groups.variable_group_ids
}
