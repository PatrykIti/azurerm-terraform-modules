output "team_id" {
  description = "ID of the Azure DevOps team."
  value       = module.azuredevops_team.team_id
}

output "team_descriptor" {
  description = "Descriptor of the Azure DevOps team."
  value       = module.azuredevops_team.team_descriptor
}
