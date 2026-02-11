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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

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
