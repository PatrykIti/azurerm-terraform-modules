output "build_definition_ids" {
  description = "Map of build definition IDs keyed by build definition key."
  value       = { for key, definition in azuredevops_build_definition.build_definition : key => definition.id }
}

output "build_folder_ids" {
  description = "Map of build folder IDs keyed by index."
  value       = { for key, folder in azuredevops_build_folder.build_folder : key => folder.id }
}
