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
  display_name = "ado-group-security-members"
  description  = "Membership source group"
}

module "azuredevops_group" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_group?ref=ADOGv1.0.0"

  group_display_name = "ado-group-security"
  group_description  = "Security reviewers"

  group_memberships = [
    {
      key                = "security-membership"
      member_descriptors = [azuredevops_group.member.descriptor]
      mode               = "overwrite"
    }
  ]
}
