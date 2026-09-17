output "extension_ids" {
  description = "Map of extension IDs keyed by publisher/extension."
  value       = { for key, mod in module.azuredevops_extension : key => mod.extension_id }
}
