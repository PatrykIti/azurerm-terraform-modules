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
    name          = "Code Wiki"
    type          = "codeWiki"
    repository_id = var.repository_id
    version       = var.repository_version
    mapped_path   = "/"
  }

  wiki_pages = {
    runbooks = {
      path    = "/Runbooks"
      content = "Runbooks and operational notes."
    }
    oncall = {
      path    = "/Runbooks/OnCall"
      content = "On-call procedures and escalation paths."
    }
  }
}
