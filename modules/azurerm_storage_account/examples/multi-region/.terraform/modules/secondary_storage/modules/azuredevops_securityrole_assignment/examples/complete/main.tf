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

module "azuredevops_securityrole_assignment" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_securityrole_assignment?ref=ADOSRAv1.0.0"

  scope       = var.scope
  resource_id = var.project_id
  role_name   = var.role_name
  identity_id = var.identity_id
}
