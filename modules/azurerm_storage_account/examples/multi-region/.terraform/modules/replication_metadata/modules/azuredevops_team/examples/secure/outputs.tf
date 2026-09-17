output "team_id" {
  description = "ID of the Azure DevOps team."
  value       = module.azuredevops_team.team_id
}

output "team_descriptor" {
  description = "Descriptor of the Azure DevOps team."
  value       = module.azuredevops_team.team_descriptor
}

output "team_administrator_ids" {
  description = "Map of team administrator assignment IDs keyed by admin key."
  value       = module.azuredevops_team.team_administrator_ids
}
