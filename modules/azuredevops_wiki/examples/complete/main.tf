provider "azuredevops" {}

module "azuredevops_wiki" {
  source = "../../"

  project_id = var.project_id

  wikis = {
    code = {
      name          = "Code Wiki"
      type          = "codeWiki"
      repository_id = var.repository_id
      version       = var.repository_version
      mapped_path   = "/"
    }
  }

  wiki_pages = [
    {
      wiki_key = "code"
      path     = "/Runbooks"
      content  = "Runbooks and operational notes."
    },
    {
      wiki_key = "code"
      path     = "/Runbooks/OnCall"
      content  = "On-call procedures and escalation paths."
    }
  ]
}
