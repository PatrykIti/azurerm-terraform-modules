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
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_wiki?ref=ADOWIv1.0.0"

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
