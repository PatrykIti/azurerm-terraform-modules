# Pipeline settings fixture (formerly network)
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

module "azuredevops_project" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  name = "ado-project-pipeline-fixture"

  pipeline_settings = {
    enforce_job_scope                    = true
    enforce_referenced_repo_scoped_token = true
    status_badges_are_private            = true
  }
}
