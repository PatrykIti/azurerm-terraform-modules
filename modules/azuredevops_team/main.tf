# Azure DevOps Team

locals {
  team_ids         = { for key, team in azuredevops_team.team : key => team.id }
  team_descriptors = { for key, team in azuredevops_team.team : key => team.descriptor }
}

resource "azuredevops_team" "team" {
  for_each = var.teams

  project_id  = var.project_id
  name        = coalesce(each.value.name, each.key)
  description = each.value.description
}

resource "azuredevops_team_members" "team_members" {
  for_each = { for index, membership in var.team_members : index => membership }

  team_id = each.value.team_id != null ? each.value.team_id : local.team_ids[each.value.team_key]
  members = each.value.member_descriptors
  mode    = each.value.mode
}

resource "azuredevops_team_administrators" "team_administrators" {
  for_each = { for index, admin in var.team_administrators : index => admin }

  team_id        = each.value.team_id != null ? each.value.team_id : local.team_ids[each.value.team_key]
  administrators = each.value.admin_descriptors
  mode           = each.value.mode
}
