data "azurerm_monitor_diagnostic_categories" "windows_function_app" {
  count      = length(var.diagnostic_settings) > 0 ? 1 : 0
  resource_id = azurerm_windows_function_app.windows_function_app.id
}

locals {
  diagnostic_log_categories = try(data.azurerm_monitor_diagnostic_categories.windows_function_app[0].log_category_types, [])
  diagnostic_metric_categories = try(
    data.azurerm_monitor_diagnostic_categories.windows_function_app[0].metric_category_types,
    data.azurerm_monitor_diagnostic_categories.windows_function_app[0].metrics,
    []
  )

  diagnostic_settings_expanded = [
    for ds in var.diagnostic_settings : merge(ds, {
      areas = ds.areas == null ? [] : [for area in ds.areas : lower(area)]
    })
  ]

  diagnostic_settings_resolved = [
    for ds in local.diagnostic_settings_expanded : merge(ds, {
      log_categories = distinct(compact(concat(
        ds.log_categories != null ? ds.log_categories : [],
        contains(ds.areas, "all") || contains(ds.areas, "logs") ? local.diagnostic_log_categories : []
      )))
      metric_categories = distinct(compact(concat(
        ds.metric_categories != null ? ds.metric_categories : [],
        contains(ds.areas, "all") || contains(ds.areas, "metrics") ? local.diagnostic_metric_categories : []
      )))
    })
  ]

  diagnostic_settings_for_each = {
    for ds in local.diagnostic_settings_resolved : ds.name => ds
    if(
      (ds.log_categories != null && length(ds.log_categories) > 0) ||
      (ds.metric_categories != null && length(ds.metric_categories) > 0)
    )
  }

  diagnostic_settings_skipped = [
    for ds in local.diagnostic_settings_resolved : {
      name              = ds.name
      areas             = ds.areas
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if(
      (ds.log_categories == null ? 0 : length(ds.log_categories)) +
      (ds.metric_categories == null ? 0 : length(ds.metric_categories))
    ) == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_settings" {
  for_each = local.diagnostic_settings_for_each

  name               = each.value.name
  target_resource_id = azurerm_windows_function_app.windows_function_app.id

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
