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

resource "azuredevops_git_repository" "wiki_repo" {
  project_id = var.project_id
  name       = "${var.wiki_name_prefix}-complete-wiki"

  initialization {
    init_type = "Clean"
  }
}

module "azuredevops_wiki" {
  source = "../../../"

  project_id = var.project_id

  wikis = {
    code = {
      name          = "${var.wiki_name_prefix}-complete"
      type          = "codeWiki"
      repository_id = azuredevops_git_repository.wiki_repo.id
      mapped_path   = "/"
    }
  }

  wiki_pages = [
    {
      wiki_key = "code"
      path     = "/Home"
      content  = "Complete wiki home page"
    },
    {
      wiki_key = "code"
      path     = "/Guides"
      content  = "Team guides"
    }
  ]
}
