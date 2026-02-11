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

locals {
  use_principal_name = var.user_principal_name != null && trimspace(var.user_principal_name) != ""
}

module "azuredevops_user_entitlement" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  user_entitlement = {
    key                  = "fixture-complete-user"
    principal_name       = local.use_principal_name ? var.user_principal_name : null
    origin               = local.use_principal_name ? null : var.user_origin
    origin_id            = local.use_principal_name ? null : var.user_origin_id
    account_license_type = "basic"
    licensing_source     = "account"
  }
}
