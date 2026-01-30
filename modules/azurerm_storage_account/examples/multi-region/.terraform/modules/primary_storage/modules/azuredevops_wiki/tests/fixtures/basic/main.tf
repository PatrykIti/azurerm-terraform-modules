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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  project_id = var.project_id

  wikis = {
    project = {
      name = "${var.wiki_name_prefix}-basic"
      type = "projectWiki"
    }
  }

  wiki_pages = [
    {
      wiki_key = "project"
      path     = "/Home"
      content  = "Basic wiki page"
    }
  ]
}
