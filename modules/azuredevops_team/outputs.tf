output "team_id" {
  description = "The ID of the Azure DevOps team."
  value       = try(azuredevops_team.team.id, null)
}

output "team_descriptor" {
  description = "The descriptor of the Azure DevOps team."
  value       = try(azuredevops_team.team.descriptor, null)
}

output "team_member_ids" {
  description = "Map of team membership IDs keyed by membership key."
  value       = try({ for key, membership in azuredevops_team_members.team_members : key => membership.id }, {})
}

output "team_administrator_ids" {
  description = "Map of team administrator assignment IDs keyed by admin key."
  value       = try({ for key, admin in azuredevops_team_administrators.team_administrators : key => admin.id }, {})
}
