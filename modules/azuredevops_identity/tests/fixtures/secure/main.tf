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

  group_display_name = "${var.group_name_prefix}-security-${random_string.suffix.result}"
  group_description  = "Security reviewers"

  group_memberships = [
    {
      key                = "security-membership"
      member_descriptors = [azuredevops_group.member.descriptor]
      mode               = "overwrite"
    }
  ]
}
