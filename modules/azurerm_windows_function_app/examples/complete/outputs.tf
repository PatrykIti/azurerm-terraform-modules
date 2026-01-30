output "function_app_id" {
  description = "The Function App ID."
  value       = module.windows_function_app.id
}

output "slot_ids" {
  description = "Slot IDs."
  value       = module.windows_function_app.slots
}
