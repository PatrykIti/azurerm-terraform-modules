locals {
  name                      = trimspace(var.name)
  role_definition_id        = var.role_definition_id == null || length(trimspace(var.role_definition_id)) == 0 ? null : trimspace(var.role_definition_id)
  description               = var.description == null || length(trimspace(var.description)) == 0 ? null : trimspace(var.description)
  scope                     = trimspace(var.scope)
  assignable_scopes         = [for scope in var.assignable_scopes : trimspace(scope)]
  has_data_actions          = anytrue([for permission in var.permissions : length(try(permission.data_actions, [])) > 0])
  uses_management_group = (
    can(regex("^/providers/Microsoft\\.Management/managementGroups/", local.scope)) ||
    anytrue([for scope in local.assignable_scopes : can(regex("^/providers/Microsoft\\.Management/managementGroups/", scope))])
  )
  assignable_scopes_in_scope = alltrue([
    for scope in local.assignable_scopes :
    scope == local.scope || startswith(scope, "${local.scope}/")
  ])
}

resource "azurerm_role_definition" "role_definition" {
  name               = local.name
  role_definition_id = local.role_definition_id
  scope              = local.scope
  description        = local.description
  assignable_scopes  = local.assignable_scopes

  dynamic "permissions" {
    for_each = var.permissions

    content {
      actions          = try(permissions.value.actions, [])
      not_actions      = try(permissions.value.not_actions, [])
      data_actions     = try(permissions.value.data_actions, [])
      not_data_actions = try(permissions.value.not_data_actions, [])
    }
  }

  dynamic "timeouts" {
    for_each = (
      var.timeouts.create != null ||
      var.timeouts.update != null ||
      var.timeouts.delete != null ||
      var.timeouts.read != null
    ) ? [var.timeouts] : []

    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
    }
  }

  lifecycle {
    precondition {
      condition     = local.assignable_scopes_in_scope
      error_message = "assignable_scopes must be the same as scope or child scopes of scope."
    }

    precondition {
      condition     = !(local.uses_management_group && local.has_data_actions)
      error_message = "data_actions are not supported when assignable_scopes include a management group scope."
    }
  }
}
