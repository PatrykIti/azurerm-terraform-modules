output "wiki_id" {
  description = "ID of the wiki created by this module."
  value       = azuredevops_wiki.wiki.id
}

output "wiki_name" {
  description = "Name of the wiki created by this module."
  value       = azuredevops_wiki.wiki.name
}

output "wiki_remote_url" {
  description = "Remote URL of the wiki created by this module."
  value       = azuredevops_wiki.wiki.remote_url
}

output "wiki_url" {
  description = "REST API URL of the wiki created by this module."
  value       = azuredevops_wiki.wiki.url
}

output "wiki_ids" {
  description = "Map containing the wiki ID under the stable key `wiki`."
  value       = { wiki = azuredevops_wiki.wiki.id }
}

output "wiki_remote_urls" {
  description = "Map containing the wiki remote URL under the stable key `wiki`."
  value       = { wiki = azuredevops_wiki.wiki.remote_url }
}

output "wiki_urls" {
  description = "Map containing the wiki REST URL under the stable key `wiki`."
  value       = { wiki = azuredevops_wiki.wiki.url }
}

output "wiki_page_ids" {
  description = "Map of wiki page IDs keyed by stable page key."
  value       = { for key, page in azuredevops_wiki_page.wiki_page : key => page.id }
}
