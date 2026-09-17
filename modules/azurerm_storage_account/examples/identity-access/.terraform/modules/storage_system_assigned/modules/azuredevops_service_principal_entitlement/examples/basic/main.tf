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

module "azuredevops_service_principal_entitlement" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_service_principal_entitlement?ref=ADOSPEv1.0.0"

  origin_id = var.service_principal_origin_id
}
