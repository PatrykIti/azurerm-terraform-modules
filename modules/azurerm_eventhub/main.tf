locals {
  namespace_id_parts = var.namespace_id == null ? [] : split("/", var.namespace_id)

  namespace_name_effective      = var.namespace_id != null ? local.namespace_id_parts[8] : var.namespace_name
  resource_group_name_effective = var.namespace_id != null ? local.namespace_id_parts[4] : var.resource_group_name

  authorization_rules = {
    for rule in var.authorization_rules : rule.name => rule
  }

  consumer_groups = {
    for group in var.consumer_groups : group.name => group
  }
}

resource "azurerm_eventhub" "eventhub" {
  name                = var.name
  namespace_id        = var.namespace_id
  namespace_name      = var.namespace_id == null ? var.namespace_name : null
  resource_group_name = var.namespace_id == null ? var.resource_group_name : null

  partition_count   = var.partition_count
  message_retention = var.retention_description == null ? var.message_retention : null
  status            = var.status

  dynamic "retention_description" {
    for_each = var.retention_description == null ? [] : [var.retention_description]
    content {
      cleanup_policy = retention_description.value.cleanup_policy

      retention_time_in_hours           = try(retention_description.value.retention_time_in_hours, null)
      tombstone_retention_time_in_hours = try(retention_description.value.tombstone_retention_time_in_hours, null)
    }
  }

  dynamic "capture_description" {
    for_each = var.capture_description == null ? [] : [var.capture_description]
    content {
      enabled             = capture_description.value.enabled
      encoding            = capture_description.value.encoding
      interval_in_seconds = try(capture_description.value.interval_in_seconds, null)
      size_limit_in_bytes = try(capture_description.value.size_limit_in_bytes, null)
      skip_empty_archives = try(capture_description.value.skip_empty_archives, null)

      destination {
        name                = try(capture_description.value.destination.name, "EventHubArchive.AzureBlockBlob")
        storage_account_id  = capture_description.value.destination.storage_account_id
        blob_container_name = capture_description.value.destination.blob_container_name
        archive_name_format = capture_description.value.destination.archive_name_format
      }
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  lifecycle {
    precondition {
      condition = (
        (var.namespace_id != null && var.namespace_id != "") &&
        (var.namespace_name == null || var.namespace_name == "") &&
        (var.resource_group_name == null || var.resource_group_name == "")
        ) || (
        (var.namespace_id == null || var.namespace_id == "") &&
        (var.namespace_name != null && var.namespace_name != "") &&
        (var.resource_group_name != null && var.resource_group_name != "")
      )
      error_message = "Provide either namespace_id OR namespace_name with resource_group_name."
    }
  }
}

resource "azurerm_eventhub_consumer_group" "consumer_groups" {
  for_each = local.consumer_groups

  name                = each.value.name
  namespace_name      = local.namespace_name_effective
  eventhub_name       = azurerm_eventhub.eventhub.name
  resource_group_name = local.resource_group_name_effective
  user_metadata       = try(each.value.user_metadata, null)
}

resource "azurerm_eventhub_authorization_rule" "authorization_rules" {
  for_each = local.authorization_rules

  name                = each.value.name
  namespace_name      = local.namespace_name_effective
  eventhub_name       = azurerm_eventhub.eventhub.name
  resource_group_name = local.resource_group_name_effective

  listen = try(each.value.listen, false)
  send   = try(each.value.send, false)
  manage = try(each.value.manage, false)
}
