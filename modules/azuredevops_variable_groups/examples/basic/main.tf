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

module "azuredevops_variable_groups" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_variable_groups?ref=ADOVGv1.0.0"

  project_id = var.project_id
  name       = "shared-vars"

  description  = "Basic variable group"
  allow_access = true

  variables = [
    {
      name  = "environment"
      value = "dev"
    },
    {
      name  = "region"
      value = "westeurope"
    }
  ]
}
