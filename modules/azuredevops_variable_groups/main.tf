locals {
  permission_value_map = {
    allow  = "Allow"
    deny   = "Deny"
    notset = "NotSet"
  }

  variable_group_variables = [
    for variable in var.variables : {
      name         = variable.name
      value        = try(variable.value, null)
      secret_value = try(variable.secret_value, null)
      is_secret    = try(variable.is_secret, null)
    }
  ]

  variable_group_permissions = {
    for permission in var.variable_group_permissions :
    coalesce(permission.key, permission.principal) => {
      principal   = permission.principal
      permissions = { for name, status in permission.permissions : name => local.permission_value_map[lower(status)] }
      replace     = try(permission.replace, true)
    }
  }
}

resource "azuredevops_variable_group" "variable_group" {
  project_id   = var.project_id
  name         = var.name
  description  = var.description
  allow_access = var.allow_access

  dynamic "variable" {
    for_each = local.variable_group_variables
    content {
      name         = variable.value.name
      value        = variable.value.secret_value == null ? variable.value.value : null
      secret_value = variable.value.secret_value
      is_secret    = variable.value.secret_value == null ? null : coalesce(variable.value.is_secret, true)
    }
  }

  dynamic "key_vault" {
    for_each = var.key_vault == null ? [] : [var.key_vault]
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
  variable_group_id = azuredevops_variable_group.variable_group.id
  principal         = each.value.principal
  permissions       = each.value.permissions
  replace           = each.value.replace
}
