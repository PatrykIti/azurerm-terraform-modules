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
    network = {
      name = "${var.wiki_name_prefix}-network"
      type = "projectWiki"
    }
  }

  wiki_pages = [
    {
      wiki_key = "network"
      path     = "/Home"
      content  = "Network fixture"
    }
  ]
}
