# Azure DevOps Team

locals {
  team_members_by_key = {
    for membership in var.team_members :
    coalesce(membership.key, membership.team_id) => {
      team_id            = coalesce(membership.team_id, azuredevops_team.team.id)
      member_descriptors = distinct(membership.member_descriptors)
      mode               = coalesce(membership.mode, "add")
    }
  }

  team_administrators_by_key = {
    for admin in var.team_administrators :
    coalesce(admin.key, admin.team_id) => {
      team_id           = coalesce(admin.team_id, azuredevops_team.team.id)
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
  team_id    = each.value.team_id
  members    = each.value.member_descriptors
  mode       = each.value.mode

  lifecycle {
    precondition {
      condition     = length(local.team_members_by_key) == length(var.team_members)
      error_message = "team_members entries must be unique by key or team_id."
    }
  }
}

resource "azuredevops_team_administrators" "team_administrators" {
  for_each = local.team_administrators_by_key

  project_id     = var.project_id
  team_id        = each.value.team_id
  administrators = each.value.admin_descriptors
  mode           = each.value.mode

  lifecycle {
    precondition {
      condition     = length(local.team_administrators_by_key) == length(var.team_administrators)
      error_message = "team_administrators entries must be unique by key or team_id."
    }
  }
}
