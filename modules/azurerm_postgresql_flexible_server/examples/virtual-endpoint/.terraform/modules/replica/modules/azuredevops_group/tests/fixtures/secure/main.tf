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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  group_display_name = "${var.group_name_prefix}-security"
  group_description  = "Security reviewers"

  group_memberships = [
    {
      key                = "security-membership"
      member_descriptors = [azuredevops_group.member.descriptor]
      mode               = "overwrite"
    }
  ]
}
