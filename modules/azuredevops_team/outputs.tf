output "team_ids" {
  description = "Map of team IDs keyed by team key."
  value       = { for key, team in azuredevops_team.team : key => team.id }
}

output "team_descriptors" {
  description = "Map of team descriptors keyed by team key."
  value       = { for key, team in azuredevops_team.team : key => team.descriptor }
}

output "team_member_ids" {
  description = "Map of team membership IDs keyed by index."
  value       = { for key, membership in azuredevops_team_members.team_members : key => membership.id }
}

output "team_administrator_ids" {
  description = "Map of team administrator assignment IDs keyed by index."
  value       = { for key, admin in azuredevops_team_administrators.team_administrators : key => admin.id }
}
