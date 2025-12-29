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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_wiki?ref=ADOWI1.0.0"

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
