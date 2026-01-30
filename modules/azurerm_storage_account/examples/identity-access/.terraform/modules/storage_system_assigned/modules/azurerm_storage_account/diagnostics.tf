# Diagnostic settings for storage account and services

locals {
  diagnostic_scope_ids = {
    storage_account = azurerm_storage_account.storage_account.id
    blob            = join("/", [azurerm_storage_account.storage_account.id, "blobServices", "default"])
    queue           = join("/", [azurerm_storage_account.storage_account.id, "queueServices", "default"])
    file            = join("/", [azurerm_storage_account.storage_account.id, "fileServices", "default"])
    table           = join("/", [azurerm_storage_account.storage_account.id, "tableServices", "default"])
    dfs             = join("/", [azurerm_storage_account.storage_account.id, "dfsServices", "default"])
  }

  monitoring_by_scope = {
    storage_account = try(var.monitoring.storage_account, [])
    blob            = try(var.monitoring.blob, [])
    queue           = try(var.monitoring.queue, [])
    file            = try(var.monitoring.file, [])
    table           = try(var.monitoring.table, [])
    dfs             = try(var.monitoring.dfs, [])
  }

  monitoring_flat = flatten([
    for scope, entries in local.monitoring_by_scope : [
      for ds in entries : merge(ds, { scope = scope })
    ]
  ])

  monitoring_for_each = {
    for ds in local.monitoring_flat : ds.name => ds
    if(
      (ds.log_categories != null && length(ds.log_categories) > 0) ||
      (ds.metric_categories != null && length(ds.metric_categories) > 0)
    )
  }

  diagnostic_settings_skipped = [
    for ds in local.monitoring_flat : {
      name              = ds.name
      scope             = ds.scope
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if(
      (ds.log_categories == null ? 0 : length(ds.log_categories)) +
      (ds.metric_categories == null ? 0 : length(ds.metric_categories))
    ) == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings" {
  for_each = local.monitoring_for_each

  name               = each.value.name
  target_resource_id = local.diagnostic_scope_ids[each.value.scope]

  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name

  dynamic "enabled_log" {
    for_each = each.value.log_categories != null ? each.value.log_categories : []
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = each.value.metric_categories != null ? each.value.metric_categories : []
    content {
      category = enabled_metric.value
    }
  }
}
