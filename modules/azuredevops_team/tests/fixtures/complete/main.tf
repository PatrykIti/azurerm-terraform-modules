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

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

data "azuredevops_group" "project_collection_valid_users" {
  name = "Project Collection Valid Users"
}

module "azuredevops_team" {
  source = "../../../"

  project_id = var.project_id

  teams = {
    platform = {
      name        = "${var.team_name_prefix}-platform"
      description = "Platform engineering team"
    }
    product = {
      name        = "${var.team_name_prefix}-product"
      description = "Product delivery team"
    }
  }

  team_members = [
    {
      key                = "platform-members"
      team_key           = "platform"
      member_descriptors = [data.azuredevops_group.project_collection_valid_users.descriptor]
    }
  ]

  team_administrators = [
    {
      key               = "platform-admins"
      team_key          = "platform"
      admin_descriptors = [data.azuredevops_group.project_collection_admins.descriptor]
    }
  ]
}
