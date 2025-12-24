output "feed_ids" {
  description = "Map of feed IDs keyed by feed key."
  value       = { for key, feed in azuredevops_feed.feed : key => feed.id }
}

output "feed_names" {
  description = "Map of feed names keyed by feed key."
  value       = { for key, feed in azuredevops_feed.feed : key => feed.name }
}

output "feed_project_ids" {
  description = "Map of feed project IDs keyed by feed key."
  value       = { for key, feed in azuredevops_feed.feed : key => feed.project_id }
}
