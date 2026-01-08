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
  user_entitlements = {
    platform = {
      principal_name       = var.platform_user_principal_name
      account_license_type = "basic"
      licensing_source     = "account"
    }
    automation = {
      origin               = var.automation_user_origin
      origin_id            = var.automation_user_origin_id
      account_license_type = "stakeholder"
      licensing_source     = "account"
    }
  }
}

module "azuredevops_user_entitlement" {
  source   = "../../"
  for_each = local.user_entitlements

  user_entitlement = merge(each.value, { key = each.key })
}
