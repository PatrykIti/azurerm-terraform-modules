output "work_item_ids" {
  description = "Work item IDs created in this fixture."
  value       = module.azuredevops_work_items.work_item_ids
}

output "query_ids" {
  description = "Query IDs created in this fixture."
  value       = module.azuredevops_work_items.query_ids
}

output "query_folder_ids" {
  description = "Query folder IDs created in this fixture."
  value       = module.azuredevops_work_items.query_folder_ids
}

output "query_permission_ids" {
  description = "Query permission IDs created in this fixture."
  value       = module.azuredevops_work_items.query_permission_ids
}
