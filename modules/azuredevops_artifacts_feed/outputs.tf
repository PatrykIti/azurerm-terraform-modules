output "feed_id" {
  description = "The ID of the Azure DevOps feed."
  value       = try(azuredevops_feed.feed[0].id, null)
}

output "feed_name" {
  description = "The name of the Azure DevOps feed."
  value       = try(azuredevops_feed.feed[0].name, null)
}

output "feed_project_id" {
  description = "The project ID associated with the Azure DevOps feed."
  value       = try(azuredevops_feed.feed[0].project_id, null)
}

output "feed_permission_ids" {
  description = "Map of feed permission IDs keyed by permission key."
  value       = { for key, permission in azuredevops_feed_permission.feed_permission : key => permission.id }
}

output "feed_retention_policy_ids" {
  description = "Map of feed retention policy IDs keyed by retention policy key."
  value       = { for key, policy in azuredevops_feed_retention_policy.feed_retention_policy : key => policy.id }
}
