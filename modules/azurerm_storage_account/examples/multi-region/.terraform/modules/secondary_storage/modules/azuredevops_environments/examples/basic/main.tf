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

module "azuredevops_environments" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_environments?ref=ADOEv1.0.0"

  project_id  = var.project_id
  name        = "ado-env-basic-example"
  description = "Development environment"
}
