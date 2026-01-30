output "linux_function_app_id" {
  description = "The ID of the created Linux Function App"
  value       = module.linux_function_app.id
}

output "linux_function_app_name" {
  description = "The name of the created Linux Function App"
  value       = module.linux_function_app.name
}
