# Azure DevOps Identity

locals {
  group_descriptors = { for key, group in azuredevops_group.group : key => group.descriptor }
  group_ids         = { for key, group in azuredevops_group.group : key => group.group_id }
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
  for_each = { for index, membership in var.group_memberships : index => membership }

  group = each.value.group_descriptor != null ? each.value.group_descriptor : local.group_descriptors[each.value.group_key]
  members = concat(
    try(each.value.member_descriptors, []),
    [for key in try(each.value.member_group_keys, []) : local.group_descriptors[key]]
  )
  mode = each.value.mode
}

resource "azuredevops_group_entitlement" "group_entitlement" {
  for_each = { for index, entitlement in var.group_entitlements : index => entitlement }

  display_name         = each.value.display_name
  origin               = each.value.origin
  origin_id            = each.value.origin_id
  account_license_type = each.value.account_license_type
  licensing_source     = each.value.licensing_source
}

resource "azuredevops_user_entitlement" "user_entitlement" {
  for_each = { for index, entitlement in var.user_entitlements : index => entitlement }

  principal_name       = each.value.principal_name
  origin               = each.value.origin
  origin_id            = each.value.origin_id
  account_license_type = each.value.account_license_type
  licensing_source     = each.value.licensing_source
}

resource "azuredevops_service_principal_entitlement" "service_principal_entitlement" {
  for_each = { for index, entitlement in var.service_principal_entitlements : index => entitlement }

  origin_id            = each.value.origin_id
  origin               = each.value.origin
  account_license_type = each.value.account_license_type
  licensing_source     = each.value.licensing_source
}

resource "azuredevops_securityrole_assignment" "securityrole_assignment" {
  for_each = { for index, assignment in var.securityrole_assignments : index => assignment }

  scope       = each.value.scope
  resource_id = each.value.resource_id
  identity_id = each.value.identity_id != null ? each.value.identity_id : local.group_ids[each.value.identity_group_key]
  role_name   = each.value.role_name
}
