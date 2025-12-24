output "team_ids" {
  description = "Map of team IDs keyed by team key."
  value       = module.azuredevops_team.team_ids
}

output "team_descriptors" {
  description = "Map of team descriptors keyed by team key."
  value       = module.azuredevops_team.team_descriptors
}
