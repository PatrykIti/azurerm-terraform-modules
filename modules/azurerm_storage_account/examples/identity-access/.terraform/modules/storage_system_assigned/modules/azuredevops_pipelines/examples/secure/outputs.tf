output "build_definition_id" {
  description = "Build definition ID created by the module."
  value       = module.azuredevops_pipelines.build_definition_id
}
