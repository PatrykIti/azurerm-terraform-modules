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

module "azuredevops_group_entitlement" {
  source = "../../../"

  group_entitlement = {
    key                  = "fixture-complete-group"
    origin               = var.group_origin
    origin_id            = var.group_origin_id
    account_license_type = "professional"
    licensing_source     = "account"
  }
}
