locals {
  identity_configured = var.identity != null
  identity_ids_set    = var.identity != null && length(coalesce(var.identity.identity_ids, [])) > 0
  identity_user_assigned = var.identity != null && contains(
    ["UserAssigned", "SystemAssigned, UserAssigned"],
    var.identity.type
  )
}

resource "azurerm_application_insights_workbook" "application_insights_workbook" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  location             = var.location
  display_name         = var.display_name
  data_json            = var.data_json
  description          = var.description
  category             = var.category
  source_id            = var.source_id
  storage_container_id = var.storage_container_id
  tags                 = var.tags

  dynamic "identity" {
    for_each = local.identity_configured ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = try(identity.value.identity_ids, null)
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
      condition     = var.storage_container_id == null || local.identity_configured
      error_message = "identity must be configured when storage_container_id is set."
    }
    precondition {
      condition     = !local.identity_user_assigned || local.identity_ids_set
      error_message = "identity.identity_ids must be provided when identity.type includes UserAssigned."
    }
    precondition {
      condition     = local.identity_user_assigned || !local.identity_ids_set
      error_message = "identity.identity_ids can only be set when identity.type includes UserAssigned."
    }
  }
}
