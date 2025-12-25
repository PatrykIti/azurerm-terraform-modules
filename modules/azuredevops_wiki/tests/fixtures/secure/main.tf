provider "azuredevops" {}

module "azuredevops_wiki" {
  source = "../../"

  project_id = var.project_id

  wikis = {
    secure = {
      name = "${var.wiki_name_prefix}-secure"
      type = "projectWiki"
    }
  }

  wiki_pages = [
    {
      wiki_key = "secure"
      path     = "/Security"
      content  = "Security guidance"
    }
  ]
}
