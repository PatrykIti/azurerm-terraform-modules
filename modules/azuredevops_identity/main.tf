# Azure DevOps Identity

locals {
  group_enabled = var.group_display_name != null || var.group_origin_id != null || var.group_mail != null

  group_descriptor = local.group_enabled ? azuredevops_group.group[0].descriptor : null
  group_id         = local.group_enabled ? azuredevops_group.group[0].group_id : null

  group_memberships = {
    for membership in var.group_memberships :
    coalesce(membership.key, membership.group_descriptor) => {
      group_descriptor   = membership.group_descriptor != null ? membership.group_descriptor : local.group_descriptor
      member_descriptors = distinct(try(membership.member_descriptors, []))
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
      assignment.identity_id,
      "${assignment.scope}/${assignment.resource_id}/${assignment.role_name}"
      ) => {
      scope       = assignment.scope
      resource_id = assignment.resource_id
      role_name   = assignment.role_name
      identity_id = assignment.identity_id != null ? assignment.identity_id : local.group_id
    }
  }
}

resource "azuredevops_group" "group" {
  count = local.group_enabled ? 1 : 0

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

  lifecycle {
    precondition {
      condition     = local.group_enabled || (each.value.group_descriptor != null && trimspace(each.value.group_descriptor) != "")
      error_message = "group_memberships.group_descriptor is required when the module group is not configured."
    }
  }
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
  identity_id = each.value.identity_id
  role_name   = each.value.role_name

  lifecycle {
    precondition {
      condition     = local.group_enabled || (each.value.identity_id != null && trimspace(each.value.identity_id) != "")
      error_message = "securityrole_assignments.identity_id is required when the module group is not configured."
    }
  }
}
