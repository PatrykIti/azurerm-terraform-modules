resource "azuredevops_wiki" "wiki" {
  project_id    = var.project_id
  name          = var.wiki.name
  type          = var.wiki.type
  repository_id = try(var.wiki.repository_id, null)
  version       = try(var.wiki.version, null)
  mapped_path   = try(var.wiki.mapped_path, null)
}

resource "azuredevops_wiki_page" "wiki_page" {
  for_each = var.wiki_pages

  project_id = var.project_id
  wiki_id    = azuredevops_wiki.wiki.id
  path       = each.value.path
  content    = each.value.content
}
