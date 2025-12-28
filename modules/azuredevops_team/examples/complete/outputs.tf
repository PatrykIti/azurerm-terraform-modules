output "team_ids" {
  description = "Map of team IDs keyed by team key."
  value       = { for key, team in module.azuredevops_team : key => team.team_id }
}

output "team_descriptors" {
  description = "Map of team descriptors keyed by team key."
  value       = { for key, team in module.azuredevops_team : key => team.team_descriptor }
}

output "team_member_ids" {
  description = "Map of team membership IDs keyed by team key."
  value       = { for key, team in module.azuredevops_team : key => team.team_member_ids }
}

output "team_administrator_ids" {
  description = "Map of team administrator assignment IDs keyed by team key."
  value       = { for key, team in module.azuredevops_team : key => team.team_administrator_ids }
}
