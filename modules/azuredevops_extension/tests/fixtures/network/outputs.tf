output "extension_ids" {
  description = "Map of extension IDs keyed by publisher/extension."
  value       = module.azuredevops_extension.extension_ids
}
