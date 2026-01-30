data "azurerm_monitor_diagnostic_categories" "linux_function_app" {
  resource_id = azurerm_linux_function_app.linux_function_app.id
}

locals {
  diagnostic_log_categories    = data.azurerm_monitor_diagnostic_categories.linux_function_app.log_category_types
  diagnostic_metric_categories = data.azurerm_monitor_diagnostic_categories.linux_function_app.metrics

  diagnostic_settings_effective = [
    for ds in var.diagnostic_settings : merge(ds, {
      log_categories = ds.log_categories != null ? ds.log_categories : (
        ds.areas == null || length(ds.areas) == 0 ? local.diagnostic_log_categories : (
          contains(ds.areas, "all") || contains(ds.areas, "logs") ? local.diagnostic_log_categories :
          [for category in local.diagnostic_log_categories : category if contains(ds.areas, category)]
        )
      )
      metric_categories = ds.metric_categories != null ? ds.metric_categories : (
        ds.areas == null || length(ds.areas) == 0 ? local.diagnostic_metric_categories : (
          contains(ds.areas, "all") || contains(ds.areas, "metrics") ? local.diagnostic_metric_categories :
          [for category in local.diagnostic_metric_categories : category if contains(ds.areas, category)]
        )
      )
    })
  ]
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_settings" {
  for_each = {
    for ds in local.diagnostic_settings_effective : ds.name => ds
    if(
      (ds.log_categories != null && length(ds.log_categories) > 0) ||
      (ds.metric_categories != null && length(ds.metric_categories) > 0)
    )
  }

  name               = each.value.name
  target_resource_id = azurerm_linux_function_app.linux_function_app.id

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
