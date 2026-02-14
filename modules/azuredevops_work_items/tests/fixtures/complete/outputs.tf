output "work_item_ids" {
  description = "Work item IDs created in this fixture."
  value = {
    parent = module.work_item_parent.work_item_id
    child  = module.work_item_child.work_item_id
  }
}
