output "process_ids" {
  description = "Process IDs created in this example."
  value       = module.azuredevops_work_items.process_ids
}

output "work_item_id" {
  description = "Work item ID created in this example."
  value       = module.azuredevops_work_items.work_item_id
}

output "query_folder_ids" {
  description = "Query folder IDs created in this example."
  value       = module.azuredevops_work_items.query_folder_ids
}

output "query_ids" {
  description = "Query IDs created in this example."
  value       = module.azuredevops_work_items.query_ids
}

output "query_permission_ids" {
  description = "Query permission IDs created in this example."
  value       = module.azuredevops_work_items.query_permission_ids
}
