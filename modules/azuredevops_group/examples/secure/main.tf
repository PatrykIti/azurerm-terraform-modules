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

  group_display_name = "${var.group_name_prefix}-security"
  group_description  = "Security reviewers"

  group_memberships = [
    {
      key                = "security-membership"
      member_descriptors = [azuredevops_group.member.descriptor]
      mode               = "overwrite"
    }
  ]

  group_entitlements = var.aad_group_display_name != "" ? [
    {
      key                  = "stakeholder-group"
      display_name         = var.aad_group_display_name
      account_license_type = "stakeholder"
      licensing_source     = "account"
    }
  ] : []
}
