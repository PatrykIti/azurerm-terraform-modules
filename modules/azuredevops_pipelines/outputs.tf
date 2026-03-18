output "build_definition_id" {
  description = "ID of the build definition created by the module."
  value       = azuredevops_build_definition.build_definition.id
}
