output "build_definition_ids" {
  description = "Build definition IDs created by the module."
  value       = { for key, mod in module.azuredevops_pipelines : key => mod.build_definition_id }
}

output "build_folder_ids" {
  description = "Build folder IDs created by the module."
  value       = module.azuredevops_pipelines["app"].build_folder_ids
}
