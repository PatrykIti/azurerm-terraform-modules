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
  source = "../../"

  group_entitlement = {
    key                  = "example-secure-group"
    display_name         = var.group_display_name
    account_license_type = "stakeholder"
    licensing_source     = "account"
  }
}
