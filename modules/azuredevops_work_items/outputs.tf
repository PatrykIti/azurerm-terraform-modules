output "process_ids" {
  description = "Map of process IDs keyed by process key."
  value       = try({ for key, process in azuredevops_workitemtrackingprocess_process.process : key => process.id }, {})
}

output "work_item_ids" {
  description = "Map of work item IDs keyed by work item key."
  value       = try({ for key, item in azuredevops_workitem.work_item : key => item.id }, {})
}

output "query_folder_ids" {
  description = "Map of query folder IDs keyed by folder key."
  value       = try({ for key, folder in azuredevops_workitemquery_folder.query_folder : key => folder.id }, {})
}

output "query_ids" {
  description = "Map of query IDs keyed by query key."
  value       = try({ for key, query in azuredevops_workitemquery.query : key => query.id }, {})
}

output "query_permission_ids" {
  description = "Map of query permission IDs keyed by permission key."
  value       = try({ for key, perm in azuredevops_workitemquery_permissions.query_permissions : key => perm.id }, {})
}

output "area_permission_ids" {
  description = "Map of area permission IDs keyed by permission key."
  value       = try({ for key, perm in azuredevops_area_permissions.area_permissions : key => perm.id }, {})
}

output "iteration_permission_ids" {
  description = "Map of iteration permission IDs keyed by permission key."
  value       = try({ for key, perm in azuredevops_iteration_permissions.iteration_permissions : key => perm.id }, {})
}

output "tagging_permission_ids" {
  description = "Map of tagging permission IDs keyed by permission key."
  value       = try({ for key, perm in azuredevops_tagging_permissions.tagging_permissions : key => perm.id }, {})
}
