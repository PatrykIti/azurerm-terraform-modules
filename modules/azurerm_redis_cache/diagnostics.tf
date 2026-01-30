data "azurerm_monitor_diagnostic_categories" "redis_cache" {
  count       = length(var.diagnostic_settings) > 0 ? 1 : 0
  resource_id = azurerm_redis_cache.redis_cache.id
}

locals {
  diagnostic_log_categories    = try(data.azurerm_monitor_diagnostic_categories.redis_cache[0].log_category_types, [])
  diagnostic_metric_categories = try(data.azurerm_monitor_diagnostic_categories.redis_cache[0].metrics, [])

  diagnostic_settings_filtered = [
    for ds in var.diagnostic_settings : merge(ds, {
      log_categories = ds.log_categories == null ? [] : [
        for c in ds.log_categories : c if contains(local.diagnostic_log_categories, c)
      ]
      metric_categories = ds.metric_categories == null ? [] : [
        for c in ds.metric_categories : c if contains(local.diagnostic_metric_categories, c)
      ]
    })
  ]

  diagnostic_settings_effective = [
    for ds in local.diagnostic_settings_filtered : ds
    if length(ds.log_categories) + length(ds.metric_categories) > 0
  ]

  diagnostic_settings_skipped = [
    for ds in local.diagnostic_settings_filtered : {
      name              = ds.name
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if length(ds.log_categories) + length(ds.metric_categories) == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings" {
  for_each = {
    for ds in local.diagnostic_settings_effective : ds.name => ds
  }

  name               = each.value.name
  target_resource_id = azurerm_redis_cache.redis_cache.id

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

  dynamic "enabled_metric" {
    for_each = each.value.metric_categories
    content {
      category = enabled_metric.value
    }
  }
}
