locals {
  variable_group_ids = { for key, group in azuredevops_variable_group.variable_group : key => group.id }
  variable_group_permissions = {
    for idx, permission in var.variable_group_permissions : idx => permission
  }
  library_permissions = {
    for idx, permission in var.library_permissions : idx => permission
  }
}

resource "azuredevops_variable_group" "variable_group" {
  for_each = var.variable_groups

  project_id   = var.project_id
  name         = coalesce(each.value.name, each.key)
  description  = each.value.description
  allow_access = try(each.value.allow_access, false)

  dynamic "variable" {
    for_each = each.value.variables
    content {
      name         = variable.value.name
      value        = try(variable.value.value, null)
      secret_value = try(variable.value.secret_value, null)
      is_secret    = try(variable.value.is_secret, null)
    }
  }

  dynamic "key_vault" {
    for_each = try(each.value.key_vaults, [])
    content {
      name                = key_vault.value.name
      service_endpoint_id = key_vault.value.service_endpoint_id
      search_depth        = try(key_vault.value.search_depth, null)
    }
  }
}

resource "azuredevops_variable_group_permissions" "variable_group_permissions" {
  for_each = local.variable_group_permissions

  project_id        = var.project_id
  variable_group_id = each.value.variable_group_id != null ? each.value.variable_group_id : local.variable_group_ids[each.value.variable_group_key]
  principal         = each.value.principal
  permissions       = each.value.permissions
  replace           = try(each.value.replace, true)
}

resource "azuredevops_library_permissions" "library_permissions" {
  for_each = local.library_permissions

  project_id  = var.project_id
  principal   = each.value.principal
  permissions = each.value.permissions
  replace     = try(each.value.replace, true)
}
