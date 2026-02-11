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

resource "azuredevops_git_repository" "example" {
  project_id = var.project_id
  name       = "repo-ado-bas-${var.random_suffix}"

  initialization {
    init_type = "Clean"
  }
}

module "azuredevops_pipelines" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  project_id = var.project_id

  name = "pip-ado-bas-${var.random_suffix}"

  repository = {
    repo_type = "TfsGit"
    repo_id   = azuredevops_git_repository.example.id
    yml_path  = var.yaml_path
  }

  ci_trigger = {
    use_yaml = true
  }
}
