locals {
  name                                    = var.name == null || length(trimspace(var.name)) == 0 ? null : trimspace(var.name)
  scope                                   = trimspace(var.scope)
  principal_id                            = trimspace(var.principal_id)
  role_definition_id                      = var.role_definition_id == null || length(trimspace(var.role_definition_id)) == 0 ? null : trimspace(var.role_definition_id)
  role_definition_name                    = var.role_definition_name == null || length(trimspace(var.role_definition_name)) == 0 ? null : trimspace(var.role_definition_name)
  principal_type                          = var.principal_type == null || length(trimspace(var.principal_type)) == 0 ? null : trimspace(var.principal_type)
  description                             = var.description == null || length(trimspace(var.description)) == 0 ? null : trimspace(var.description)
  condition                               = var.condition == null || length(trimspace(var.condition)) == 0 ? null : trimspace(var.condition)
  condition_version                       = var.condition_version == null || length(trimspace(var.condition_version)) == 0 ? null : trimspace(var.condition_version)
  delegated_managed_identity_resource_id  = var.delegated_managed_identity_resource_id == null || length(trimspace(var.delegated_managed_identity_resource_id)) == 0 ? null : trimspace(var.delegated_managed_identity_resource_id)
  role_definition_id_set                  = local.role_definition_id != null
  role_definition_name_set                = local.role_definition_name != null
  condition_set                           = local.condition != null
  condition_version_set                   = local.condition_version != null
  delegated_managed_identity_resource_set = local.delegated_managed_identity_resource_id != null
}

resource "azurerm_role_assignment" "role_assignment" {
  name                                   = local.name
  scope                                  = local.scope
  role_definition_id                     = local.role_definition_id
  role_definition_name                   = local.role_definition_name
  principal_id                           = local.principal_id
  principal_type                         = local.principal_type
  description                            = local.description
  condition                              = local.condition
  condition_version                      = local.condition_version
  delegated_managed_identity_resource_id = local.delegated_managed_identity_resource_id
  skip_service_principal_aad_check       = var.skip_service_principal_aad_check

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
      condition     = local.role_definition_id_set != local.role_definition_name_set
      error_message = "Exactly one of role_definition_id or role_definition_name must be set."
    }

    precondition {
      condition     = !local.condition_set || local.condition_version_set
      error_message = "condition_version must be set when condition is provided."
    }

    precondition {
      condition     = !local.condition_version_set || local.condition_set
      error_message = "condition must be set when condition_version is provided."
    }

    precondition {
      condition     = !var.skip_service_principal_aad_check || local.principal_type == "ServicePrincipal"
      error_message = "skip_service_principal_aad_check can only be used when principal_type is ServicePrincipal."
    }

    precondition {
      condition     = !local.delegated_managed_identity_resource_set || local.principal_type == "ServicePrincipal"
      error_message = "delegated_managed_identity_resource_id requires principal_type to be ServicePrincipal."
    }
  }
}
