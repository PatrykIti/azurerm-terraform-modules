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

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_identity" {
  source = "../../../"

  groups = {
    platform = {
      display_name = "${var.group_name_prefix}-platform-${random_string.suffix.result}"
      description  = "Platform engineering group"
    }
    developers = {
      display_name = "${var.group_name_prefix}-developers-${random_string.suffix.result}"
      description  = "Development contributors"
    }
  }

  group_memberships = [
    {
      key               = "platform-membership"
      group_key         = "platform"
      member_group_keys = ["developers"]
      mode              = "add"
    }
  ]

  user_entitlements = var.user_principal_name != "" ? [
    {
      key                  = "fixture-user"
      principal_name       = var.user_principal_name
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ] : []
}
