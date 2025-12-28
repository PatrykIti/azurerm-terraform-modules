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

module "azuredevops_team" {
  source = "../../../"

  project_id  = var.project_id
  name        = "ado-team-bas-${var.random_suffix}"
  description = "Test core team"
}
