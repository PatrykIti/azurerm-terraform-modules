data "azurerm_monitor_diagnostic_categories" "ai_services" {
  count       = length(var.diagnostic_settings) > 0 ? 1 : 0
  resource_id = azurerm_ai_services.ai_services.id
}

locals {
  diagnostic_log_categories    = try(data.azurerm_monitor_diagnostic_categories.ai_services[0].log_category_types, [])
  diagnostic_metric_categories = try(data.azurerm_monitor_diagnostic_categories.ai_services[0].metrics, [])

  diagnostic_settings_expanded = [
    for ds in var.diagnostic_settings : merge(ds, {
      areas       = coalesce(ds.areas, [])
      areas_lower = [for area in coalesce(ds.areas, []) : lower(area)]
    })
  ]

  diagnostic_settings_resolved = [
    for ds in local.diagnostic_settings_expanded : merge(ds, {
      log_categories = ds.log_categories != null ? ds.log_categories : (
        length(ds.areas_lower) == 0 ? local.diagnostic_log_categories : (
          contains(ds.areas_lower, "all") || contains(ds.areas_lower, "logs") ?
          local.diagnostic_log_categories :
          [for category in local.diagnostic_log_categories : category if contains(ds.areas, category)]
        )
      )
      metric_categories = ds.metric_categories != null ? ds.metric_categories : (
        length(ds.areas_lower) == 0 ? local.diagnostic_metric_categories : (
          contains(ds.areas_lower, "all") || contains(ds.areas_lower, "metrics") ?
          local.diagnostic_metric_categories :
          [for category in local.diagnostic_metric_categories : category if contains(ds.areas, category)]
        )
      )
    })
  ]

  diagnostic_settings_by_name = {
    for ds in var.diagnostic_settings : ds.name => ds
    if(
      (ds.log_categories != null && length(ds.log_categories) > 0) ||
      (ds.metric_categories != null && length(ds.metric_categories) > 0) ||
      (ds.areas != null && length(ds.areas) > 0) ||
      (ds.log_categories == null && ds.metric_categories == null && (ds.areas == null || length(ds.areas) == 0))
    )
  }

  diagnostic_settings_resolved_by_name = {
    for ds in local.diagnostic_settings_resolved : ds.name => ds
  }

  diagnostic_settings_skipped = [
    for ds in local.diagnostic_settings_resolved : {
      name              = ds.name
      areas             = ds.areas
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if length(ds.log_categories) + length(ds.metric_categories) == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings" {
  for_each = local.diagnostic_settings_by_name

  name               = each.value.name
  target_resource_id = azurerm_ai_services.ai_services.id

  log_analytics_workspace_id     = try(each.value.log_analytics_workspace_id, null)
  log_analytics_destination_type = try(each.value.log_analytics_destination_type, null)
  storage_account_id             = try(each.value.storage_account_id, null)
  eventhub_authorization_rule_id = try(each.value.eventhub_authorization_rule_id, null)
  eventhub_name                  = try(each.value.eventhub_name, null)

  dynamic "enabled_log" {
    for_each = try(local.diagnostic_settings_resolved_by_name[each.key].log_categories, [])
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = try(local.diagnostic_settings_resolved_by_name[each.key].metric_categories, [])
    content {
      category = enabled_metric.value
    }
  }
}
