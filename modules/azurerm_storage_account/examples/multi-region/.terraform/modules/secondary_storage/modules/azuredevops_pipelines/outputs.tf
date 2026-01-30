output "build_definition_id" {
  description = "ID of the build definition created by the module."
  value       = try(azuredevops_build_definition.build_definition.id, null)
}

output "build_folder_ids" {
  description = "Map of build folder IDs keyed by folder key or path."
  value       = { for key, folder in azuredevops_build_folder.build_folder : key => folder.id }
}
