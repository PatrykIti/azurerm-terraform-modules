# Team administrator fixture (optional inputs)
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

  project_id = var.project_id

  teams = {
    audit = {
      name        = var.team_name
      description = "Audit team fixture"
    }
  }

  team_administrators = var.team_administrators
}
