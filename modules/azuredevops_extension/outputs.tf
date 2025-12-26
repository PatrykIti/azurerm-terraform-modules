output "extension_id" {
  description = "The ID of the Azure DevOps extension."
  value       = try(azuredevops_extension.extension.id, null)
}
