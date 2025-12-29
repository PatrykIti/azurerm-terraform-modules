terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

module "azuredevops_wiki" {
  source = "../../"

  project_id = var.project_id

  wikis = {
    project = {
      name = "Secure Wiki"
      type = "projectWiki"
    }
  }

  wiki_pages = [
    {
      wiki_key = "project"
      path     = "/Security"
      content  = "Security guidelines (no secrets stored here)."
    }
  ]
}
