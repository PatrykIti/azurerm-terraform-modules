locals {
  diagnostic_settings_normalized = [
    for ds in var.diagnostic_settings : merge(ds, {
      log_categories    = coalesce(ds.log_categories, [])
      metric_categories = coalesce(ds.metric_categories, [])
    })
  ]

  diagnostic_settings_for_each = {
    for ds in local.diagnostic_settings_normalized : ds.name => ds
    if length(ds.log_categories) + length(ds.metric_categories) > 0
  }

  diagnostic_settings_skipped = [
    for ds in local.diagnostic_settings_normalized : {
      name              = ds.name
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if length(ds.log_categories) + length(ds.metric_categories) == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  for_each = local.diagnostic_settings_for_each

  name               = each.value.name
  target_resource_id = azurerm_redis_cache.redis_cache.id

  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name

  dynamic "enabled_log" {
    for_each = toset(each.value.log_categories)
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(each.value.metric_categories)
    content {
      category = enabled_metric.value
    }
  }
}
