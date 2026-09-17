locals {
  wiki_ids   = { for key, wiki in azuredevops_wiki.wiki : key => wiki.id }
  wiki_pages = { for idx, page in var.wiki_pages : idx => page }
}

resource "azuredevops_wiki" "wiki" {
  for_each = var.wikis

  project_id    = var.project_id
  name          = coalesce(each.value.name, each.key)
  type          = each.value.type
  repository_id = try(each.value.repository_id, null)
  version       = try(each.value.version, null)
  mapped_path   = try(each.value.mapped_path, null)
}

resource "azuredevops_wiki_page" "wiki_page" {
  for_each = local.wiki_pages

  project_id = var.project_id
  wiki_id    = each.value.wiki_id != null ? each.value.wiki_id : local.wiki_ids[each.value.wiki_key]
  path       = each.value.path
  content    = each.value.content
}
