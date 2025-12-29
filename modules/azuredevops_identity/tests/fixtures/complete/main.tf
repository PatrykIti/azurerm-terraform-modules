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

resource "azuredevops_group" "member" {
  display_name = "${var.group_name_prefix}-members-${random_string.suffix.result}"
  description  = "Membership source group"
}

module "azuredevops_identity" {
  source = "../../../"

  group_display_name = "${var.group_name_prefix}-platform-${random_string.suffix.result}"
  group_description  = "Platform engineering group"

  group_memberships = [
    {
      key                = "platform-membership"
      member_descriptors = [azuredevops_group.member.descriptor]
      mode               = "add"
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
