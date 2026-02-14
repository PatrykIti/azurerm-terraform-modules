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

resource "azuredevops_git_repository_file" "wiki_seed" {
  repository_id       = azuredevops_git_repository.wiki_repo.id
  file                = "README.md"
  content             = "# Wiki Repository\n\nSeed commit for wiki tests."
  branch              = "refs/heads/master"
  commit_message      = "Initialize wiki repository"
  overwrite_on_create = true
}

module "azuredevops_wiki" {
  source = "../../../"

  project_id = var.project_id

  wiki = {
    name          = "${var.wiki_name_prefix}-complete"
    type          = "codeWiki"
    repository_id = azuredevops_git_repository.wiki_repo.id
    version       = "master"
    mapped_path   = "/"
  }

  wiki_pages = {
    runbooks = {
      path    = "/Runbooks"
      content = "Runbooks and operational notes."
    }
  }

  depends_on = [azuredevops_git_repository_file.wiki_seed]
}
