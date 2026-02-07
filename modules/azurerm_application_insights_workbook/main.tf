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
    for_each = var.identity == null ? [] : [var.identity]
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
}
