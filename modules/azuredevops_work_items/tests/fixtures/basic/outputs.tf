output "work_item_ids" {
  description = "Work item IDs created in this fixture."
  value       = module.azuredevops_work_items.work_item_ids
}
