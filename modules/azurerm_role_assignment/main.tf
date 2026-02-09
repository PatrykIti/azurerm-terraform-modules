resource "azurerm_role_assignment" "role_assignment" {
  name  = var.name == null || length(trimspace(var.name)) == 0 ? null : trimspace(var.name)
  scope = trimspace(var.scope)

  role_definition_id   = var.role_definition_id == null || length(trimspace(var.role_definition_id)) == 0 ? null : trimspace(var.role_definition_id)
  role_definition_name = var.role_definition_name == null || length(trimspace(var.role_definition_name)) == 0 ? null : trimspace(var.role_definition_name)

  principal_id   = trimspace(var.principal_id)
  principal_type = var.principal_type == null || length(trimspace(var.principal_type)) == 0 ? null : trimspace(var.principal_type)

  description       = var.description == null || length(trimspace(var.description)) == 0 ? null : trimspace(var.description)
  condition         = var.condition == null || length(trimspace(var.condition)) == 0 ? null : trimspace(var.condition)
  condition_version = var.condition_version == null || length(trimspace(var.condition_version)) == 0 ? null : trimspace(var.condition_version)

  delegated_managed_identity_resource_id = var.delegated_managed_identity_resource_id == null || length(trimspace(var.delegated_managed_identity_resource_id)) == 0 ? null : trimspace(var.delegated_managed_identity_resource_id)
  skip_service_principal_aad_check       = var.skip_service_principal_aad_check

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : (
      var.timeouts.create != null ||
      var.timeouts.delete != null ||
      var.timeouts.read != null
    ) ? [var.timeouts] : []

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
    }
  }
}
