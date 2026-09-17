output "work_item_id" {
  description = "Work item ID created in this example."
  value       = module.azuredevops_work_items.work_item_id
}

output "area_permission_ids" {
  description = "Area permission IDs created in this example."
  value       = module.azuredevops_work_items.area_permission_ids
}

output "iteration_permission_ids" {
  description = "Iteration permission IDs created in this example."
  value       = module.azuredevops_work_items.iteration_permission_ids
}

output "tagging_permission_ids" {
  description = "Tagging permission IDs created in this example."
  value       = module.azuredevops_work_items.tagging_permission_ids
}
