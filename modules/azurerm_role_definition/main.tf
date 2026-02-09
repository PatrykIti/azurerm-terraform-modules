resource "azurerm_role_definition" "role_definition" {
  name               = trimspace(var.name)
  role_definition_id = var.role_definition_id == null || length(trimspace(var.role_definition_id)) == 0 ? null : trimspace(var.role_definition_id)
  scope              = trimspace(var.scope)
  description        = var.description == null || length(trimspace(var.description)) == 0 ? null : trimspace(var.description)
  assignable_scopes  = [for assignable_scope in var.assignable_scopes : trimspace(assignable_scope)]

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
}
