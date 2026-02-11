output "linux_function_app_id" {
  description = "The ID of the created Linux Function App"
  value       = module.linux_function_app.id
}

output "slot_ids" {
  description = "The IDs of the created slots"
  value       = { for name, slot in module.linux_function_app.slots : name => slot.id }
}
