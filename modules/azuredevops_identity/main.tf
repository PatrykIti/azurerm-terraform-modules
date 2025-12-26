# Azure DevOps Identity

locals {
  group_descriptors = { for key, group in azuredevops_group.group : key => group.descriptor }
  group_ids         = { for key, group in azuredevops_group.group : key => group.group_id }
  group_memberships = {
    for membership in var.group_memberships :
    coalesce(membership.key, membership.group_descriptor, membership.group_key) => {
      group_descriptor   = membership.group_descriptor
      group_key          = membership.group_key
      member_descriptors = try(membership.member_descriptors, [])
      member_group_keys  = try(membership.member_group_keys, [])
      mode               = coalesce(membership.mode, "add")
    }
  }
  group_entitlements = {
    for entitlement in var.group_entitlements :
    coalesce(entitlement.key, entitlement.display_name, entitlement.origin_id) => entitlement
  }
  user_entitlements = {
    for entitlement in var.user_entitlements :
    coalesce(entitlement.key, entitlement.principal_name, entitlement.origin_id) => entitlement
  }
  service_principal_entitlements = {
    for entitlement in var.service_principal_entitlements :
    coalesce(entitlement.key, entitlement.origin_id) => entitlement
  }
  securityrole_assignments = {
    for assignment in var.securityrole_assignments :
    coalesce(
      assignment.key,
      "${assignment.scope}/${assignment.resource_id}/${assignment.role_name}/${coalesce(assignment.identity_id, assignment.identity_group_key, "unknown")}"
    ) => assignment
  }
}

resource "azuredevops_group" "group" {
  for_each = var.groups

  scope        = each.value.scope
  origin_id    = each.value.origin_id
  origin       = each.value.origin
  mail         = each.value.mail
  display_name = each.value.display_name
  description  = each.value.description
}

resource "azuredevops_group_membership" "group_membership" {
  for_each = local.group_memberships

  group = each.value.group_descriptor != null ? each.value.group_descriptor : local.group_descriptors[each.value.group_key]
  members = distinct(concat(
    each.value.member_descriptors,
    [for key in each.value.member_group_keys : local.group_descriptors[key]]
  ))
  mode = each.value.mode
}

resource "azuredevops_group_entitlement" "group_entitlement" {
  for_each = local.group_entitlements

  display_name         = each.value.display_name
  origin               = each.value.origin
  origin_id            = each.value.origin_id
  account_license_type = each.value.account_license_type
  licensing_source     = each.value.licensing_source
}

resource "azuredevops_user_entitlement" "user_entitlement" {
  for_each = local.user_entitlements

  principal_name       = each.value.principal_name
  origin               = each.value.origin
  origin_id            = each.value.origin_id
  account_license_type = each.value.account_license_type
  licensing_source     = each.value.licensing_source
}

resource "azuredevops_service_principal_entitlement" "service_principal_entitlement" {
  for_each = local.service_principal_entitlements

  origin_id            = each.value.origin_id
  origin               = each.value.origin
  account_license_type = each.value.account_license_type
  licensing_source     = each.value.licensing_source
}

resource "azuredevops_securityrole_assignment" "securityrole_assignment" {
  for_each = local.securityrole_assignments

  scope       = each.value.scope
  resource_id = each.value.resource_id
  identity_id = each.value.identity_id != null ? each.value.identity_id : local.group_ids[each.value.identity_group_key]
  role_name   = each.value.role_name
}
