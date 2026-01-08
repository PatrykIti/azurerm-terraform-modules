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
  source = "../../../"

  user_entitlement = {
    key                  = "fixture-complete-user"
    origin               = var.user_origin
    origin_id            = var.user_origin_id
    account_license_type = "basic"
    licensing_source     = "account"
  }
}
