output "function_app_id" {
  description = "The Function App ID."
  value       = module.windows_function_app.id
}

output "default_hostname" {
  description = "The default hostname."
  value       = module.windows_function_app.default_hostname
}
