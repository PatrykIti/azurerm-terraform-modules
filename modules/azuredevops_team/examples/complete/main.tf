provider "azuredevops" {}

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

data "azuredevops_group" "project_collection_valid_users" {
  name = "Project Collection Valid Users"
}

locals {
  teams = {
    platform = {
      name        = "${var.team_name_prefix}-platform"
      description = "Platform engineering team"
      members     = [data.azuredevops_group.project_collection_valid_users.descriptor]
      admins      = [data.azuredevops_group.project_collection_admins.descriptor]
    }
    product = {
      name        = "${var.team_name_prefix}-product"
      description = "Product delivery team"
      members     = [data.azuredevops_group.project_collection_valid_users.descriptor]
      admins      = []
    }
  }
}

module "azuredevops_team" {
  source   = "../../"
  for_each = local.teams

  project_id  = var.project_id
  name        = each.value.name
  description = each.value.description

  team_members = [
    {
      key                = "${each.key}-members"
      member_descriptors = each.value.members
    }
  ]

  team_administrators = length(each.value.admins) > 0 ? [
    {
      key               = "${each.key}-admins"
      admin_descriptors = each.value.admins
    }
  ] : []
}
