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

resource "azuredevops_group" "member" {
  display_name = "${var.group_name_prefix}-members"
  description  = "Membership source group"
}

module "azuredevops_group" {
  source = "../../"

  group_display_name = "${var.group_name_prefix}-platform"
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
      key                  = "user-entitlement"
      principal_name       = var.user_principal_name
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ] : []

  group_entitlements = var.aad_group_display_name != "" ? [
    {
      key                  = "group-entitlement"
      display_name         = var.aad_group_display_name
      account_license_type = "basic"
      licensing_source     = "account"
    }
  ] : []
}
