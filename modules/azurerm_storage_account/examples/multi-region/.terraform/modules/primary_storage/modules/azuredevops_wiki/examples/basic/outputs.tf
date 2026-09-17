output "wiki_ids" {
  description = "Wiki IDs created in this example."
  value       = module.azuredevops_wiki.wiki_ids
}

output "wiki_page_ids" {
  description = "Wiki page IDs created in this example."
  value       = module.azuredevops_wiki.wiki_page_ids
}
