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

  wiki = {
    name = "${var.wiki_name_prefix}-invalid"
    type = "projectWiki"
  }

  wiki_pages = {
    page_a = {
      path    = "/Duplicate"
      content = "A"
    }
    page_b = {
      path    = "/Duplicate"
      content = "B"
    }
  }
}
