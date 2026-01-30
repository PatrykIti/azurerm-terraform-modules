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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  origin_id            = var.service_principal_origin_id
  origin               = "aad"
  account_license_type = "stakeholder"
  licensing_source     = "account"
}
