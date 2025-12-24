output "extension_ids" {
  description = "Map of extension IDs keyed by publisher/extension."
  value       = { for key, extension in azuredevops_extension.extension : key => extension.id }
}
