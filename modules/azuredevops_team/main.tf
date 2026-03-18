# Azure DevOps Team

locals {
  team_members_by_key = {
    for membership in var.team_members : membership.key => {
      member_descriptors = distinct(membership.member_descriptors)
      mode               = coalesce(membership.mode, "add")
    }
  }

  team_administrators_by_key = {
    for admin in var.team_administrators : admin.key => {
      admin_descriptors = distinct(admin.admin_descriptors)
      mode              = coalesce(admin.mode, "add")
    }
  }
}

resource "azuredevops_team" "team" {
  project_id  = var.project_id
  name        = var.name
  description = var.description
}

resource "azuredevops_team_members" "team_members" {
  for_each = local.team_members_by_key

  project_id = var.project_id
  team_id    = azuredevops_team.team.id
  members    = each.value.member_descriptors
  mode       = each.value.mode
}

resource "azuredevops_team_administrators" "team_administrators" {
  for_each = local.team_administrators_by_key

  project_id     = var.project_id
  team_id        = azuredevops_team.team.id
  administrators = each.value.admin_descriptors
  mode           = each.value.mode
}
