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
  source = "../../../"

  service_principal_entitlements = [
    {
      key                  = "fixture-sp"
      origin_id            = var.service_principal_origin_id
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ]
}
