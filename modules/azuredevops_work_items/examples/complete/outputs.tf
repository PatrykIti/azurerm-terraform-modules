output "process_ids" {
  description = "Process IDs created in this example."
  value       = module.azuredevops_work_items.process_ids
}

output "work_item_ids" {
  description = "Work item IDs created in this example."
  value       = module.azuredevops_work_items.work_item_ids
}

output "query_ids" {
  description = "Query IDs created in this example."
  value       = module.azuredevops_work_items.query_ids
}
