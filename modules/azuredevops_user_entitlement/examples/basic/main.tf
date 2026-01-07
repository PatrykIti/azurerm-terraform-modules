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

module "azuredevops_user_entitlement" {
  source = "../../"

  user_entitlements = [
    {
      key                  = "basic-user"
      principal_name       = var.user_principal_name
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ]
}
