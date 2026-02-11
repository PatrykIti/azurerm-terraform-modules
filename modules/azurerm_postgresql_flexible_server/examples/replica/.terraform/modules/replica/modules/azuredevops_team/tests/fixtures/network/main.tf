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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  project_id  = var.project_id
  name        = "ado-team-net-${var.random_suffix}"
  description = "Audit team fixture"

  team_administrators = var.team_administrators
}
