output "build_definition_ids" {
  description = "Build definition IDs created by the module."
  value       = module.azuredevops_pipelines.build_definition_ids
}
