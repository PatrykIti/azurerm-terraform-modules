output "process_ids" {
  description = "Map of process IDs keyed by process key."
  value       = { for key, process in azuredevops_workitemtrackingprocess_process.process : key => process.id }
}

output "work_item_ids" {
  description = "Map of work item IDs keyed by index."
  value       = { for key, item in azuredevops_workitem.work_item : key => item.id }
}

output "query_ids" {
  description = "Map of query IDs keyed by index."
  value       = { for key, query in azuredevops_workitemquery.query : key => query.id }
}
