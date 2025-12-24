output "team_ids" {
  description = "Map of team IDs keyed by team key."
  value       = module.azuredevops_team.team_ids
}

output "team_descriptors" {
  description = "Map of team descriptors keyed by team key."
  value       = module.azuredevops_team.team_descriptors
}

output "team_member_ids" {
  description = "Map of team membership IDs keyed by index."
  value       = module.azuredevops_team.team_member_ids
}

output "team_administrator_ids" {
  description = "Map of team administrator assignment IDs keyed by index."
  value       = module.azuredevops_team.team_administrator_ids
}
