provider "azuredevops" {}

module "azuredevops_wiki" {
  source = "../../"

  project_id = var.project_id

  wikis = {
    project = {
      name = "Project Wiki"
      type = "projectWiki"
    }
  }

  wiki_pages = [
    {
      wiki_key = "project"
      path     = "/Home"
      content  = "Welcome to the project wiki."
    }
  ]
}
