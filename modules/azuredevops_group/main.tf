# Azure DevOps Group

locals {
  # Normalized map of memberships keyed by explicit membership key.
  group_memberships = {
    for membership in var.group_memberships : membership.key => {
      member_descriptors = distinct(membership.member_descriptors)
      mode               = membership.mode
    }
  }
}

resource "azuredevops_group" "group" {
  scope        = var.group_scope
  origin_id    = var.group_origin_id
  mail         = var.group_mail
  display_name = var.group_display_name
  description  = var.group_description
}

resource "azuredevops_group_membership" "group_membership" {
  for_each = local.group_memberships

  group   = azuredevops_group.group.descriptor
  members = each.value.member_descriptors
  mode    = each.value.mode
}
