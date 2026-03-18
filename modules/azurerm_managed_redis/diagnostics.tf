resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings_logs" {
  for_each = {
    for ds in var.monitoring : ds.name => ds
    if(ds.log_categories != null && length(ds.log_categories) > 0)
  }

  name               = each.value.name
  target_resource_id = azurerm_managed_redis.managed_redis.default_database[0].id

  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings_metrics" {
  for_each = {
    for ds in var.monitoring : ds.name => ds
    if(ds.metric_categories != null && length(ds.metric_categories) > 0)
  }

  name               = each.value.name
  target_resource_id = azurerm_managed_redis.managed_redis.id

  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name

  dynamic "enabled_metric" {
    for_each = each.value.metric_categories
    content {
      category = enabled_metric.value
    }
  }
}
