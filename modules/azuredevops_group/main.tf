# Azure DevOps Group

locals {
  # Descriptor/ID of the module-managed group (anchor for all sub-resources)
  group_descriptor = azuredevops_group.group.descriptor
  group_id         = azuredevops_group.group.group_id

  # Normalized map of memberships keyed by explicit key or descriptor; defaults to module group
  group_memberships = {
    for membership in var.group_memberships :
    coalesce(membership.key, membership.group_descriptor) => {
      group_descriptor   = membership.group_descriptor != null ? membership.group_descriptor : local.group_descriptor
      member_descriptors = distinct(try(membership.member_descriptors, []))
      mode               = coalesce(membership.mode, "add")
    }
  }

  # Normalized map of group entitlements keyed by explicit key or selector
  group_entitlements = {
    for entitlement in var.group_entitlements :
    coalesce(entitlement.key, entitlement.display_name, entitlement.origin_id) => entitlement
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

  group   = each.value.group_descriptor
  members = each.value.member_descriptors
  mode    = each.value.mode
}

resource "azuredevops_group_entitlement" "group_entitlement" {
  for_each = local.group_entitlements

  display_name         = each.value.display_name
  origin               = each.value.origin
  origin_id            = each.value.origin_id
  account_license_type = each.value.account_license_type
  licensing_source     = each.value.licensing_source
}
