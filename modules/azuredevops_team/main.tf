# Azure DevOps Team

locals {
  team_ids         = { for key, team in azuredevops_team.team : key => team.id }
  team_descriptors = { for key, team in azuredevops_team.team : key => team.descriptor }

  team_members_by_key = {
    for membership in var.team_members :
    coalesce(membership.key, membership.team_id, membership.team_key) => {
      team_id            = membership.team_id != null ? membership.team_id : local.team_ids[membership.team_key]
      member_descriptors = distinct(membership.member_descriptors)
      mode               = coalesce(membership.mode, "add")
    }
  }

  team_administrators_by_key = {
    for admin in var.team_administrators :
    coalesce(admin.key, admin.team_id, admin.team_key) => {
      team_id           = admin.team_id != null ? admin.team_id : local.team_ids[admin.team_key]
      admin_descriptors = distinct(admin.admin_descriptors)
      mode              = coalesce(admin.mode, "add")
    }
  }
}

resource "azuredevops_team" "team" {
  for_each = var.teams

  project_id  = var.project_id
  name        = coalesce(each.value.name, each.key)
  description = each.value.description
}

resource "azuredevops_team_members" "team_members" {
  for_each = local.team_members_by_key

  team_id = each.value.team_id
  members = each.value.member_descriptors
  mode    = each.value.mode
}

resource "azuredevops_team_administrators" "team_administrators" {
  for_each = local.team_administrators_by_key

  team_id        = each.value.team_id
  administrators = each.value.admin_descriptors
  mode           = each.value.mode
}
