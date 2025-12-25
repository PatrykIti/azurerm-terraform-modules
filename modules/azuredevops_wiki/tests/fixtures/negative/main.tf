provider "azuredevops" {}

module "azuredevops_wiki" {
  source = "../../"

  project_id = var.project_id

  wikis = {
    project = {
      name = "${var.wiki_name_prefix}-invalid"
      type = "projectWiki"
    }
  }

  wiki_pages = [
    {
      path    = "/Invalid"
      content = "Missing wiki_id and wiki_key"
    }
  ]
}
