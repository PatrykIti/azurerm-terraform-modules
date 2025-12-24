output "build_definition_ids" {
  description = "Build definition IDs created by the module."
  value       = module.azuredevops_pipelines.build_definition_ids
}

output "build_folder_ids" {
  description = "Build folder IDs created by the module."
  value       = module.azuredevops_pipelines.build_folder_ids
}
