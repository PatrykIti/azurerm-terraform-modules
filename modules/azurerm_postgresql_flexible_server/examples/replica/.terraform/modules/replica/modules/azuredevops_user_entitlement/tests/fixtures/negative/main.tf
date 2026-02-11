terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

# Negative test case - should fail validation
provider "azuredevops" {}

module "azuredevops_user_entitlement" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  user_entitlement = {
    key                  = "fixture-negative-user"
    principal_name       = var.user_principal_name
    origin               = var.user_origin
    origin_id            = var.user_origin_id
    account_license_type = "basic"
    licensing_source     = "account"
  }
}
