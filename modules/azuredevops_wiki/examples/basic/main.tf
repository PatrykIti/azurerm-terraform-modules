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

  wiki = {
    name = "Project Wiki"
    type = "projectWiki"
  }

  wiki_pages = {
    home = {
      path    = "/Home"
      content = "Welcome to the project wiki."
    }
  }
}
