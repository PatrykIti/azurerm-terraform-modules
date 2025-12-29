output "work_item_ids" {
  description = "Work item IDs created in this fixture."
  value = {
    parent = module.work_item_parent.work_item_id
    child  = module.work_item_child.work_item_id
  }
}

output "query_ids" {
  description = "Query IDs created in this fixture."
  value       = module.work_item_parent.query_ids
}

output "query_folder_ids" {
  description = "Query folder IDs created in this fixture."
  value       = module.work_item_parent.query_folder_ids
}

output "query_permission_ids" {
  description = "Query permission IDs created in this fixture."
  value       = module.work_item_parent.query_permission_ids
}
