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

module "azuredevops_project_permissions" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_project_permissions?ref=ADOPPv1.1.1"

  project_id = var.project_id

  permissions = [
    {
      key        = "project-readers"
      group_name = var.project_group_name
      scope      = "project"
      permissions = {
        GENERIC_READ  = "Allow"
        GENERIC_WRITE = "NotSet"
      }
      replace = false
    }
  ]
}
