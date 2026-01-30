output "wiki_ids" {
  description = "Map of wiki IDs keyed by wiki key."
  value       = { for key, wiki in azuredevops_wiki.wiki : key => wiki.id }
}

output "wiki_remote_urls" {
  description = "Map of wiki remote URLs keyed by wiki key."
  value       = { for key, wiki in azuredevops_wiki.wiki : key => wiki.remote_url }
}

output "wiki_urls" {
  description = "Map of wiki REST URLs keyed by wiki key."
  value       = { for key, wiki in azuredevops_wiki.wiki : key => wiki.url }
}

output "wiki_page_ids" {
  description = "Map of wiki page IDs keyed by index."
  value       = { for key, page in azuredevops_wiki_page.wiki_page : key => page.id }
}
