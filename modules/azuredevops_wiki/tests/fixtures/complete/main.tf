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
  source = "../../../"

  project_id = var.project_id

  wikis = {
    project = {
      name = "${var.wiki_name_prefix}-complete"
      type = "projectWiki"
    }
  }

  wiki_pages = [
    {
      wiki_key = "project"
      path     = "/Home"
      content  = "Complete wiki home page"
    },
    {
      wiki_key = "project"
      path     = "/Guides"
      content  = "Team guides"
    }
  ]
}
