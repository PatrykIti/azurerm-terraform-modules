data "azurerm_monitor_diagnostic_categories" "eventhub_namespace" {
  count       = length(var.diagnostic_settings) > 0 ? 1 : 0
  resource_id = azurerm_eventhub_namespace.namespace.id
}

locals {
  eventhub_diag_log_categories    = try(data.azurerm_monitor_diagnostic_categories.eventhub_namespace[0].log_category_types, [])
  eventhub_diag_metric_categories = try(data.azurerm_monitor_diagnostic_categories.eventhub_namespace[0].metrics, [])

  eventhub_area_log_map_raw = {
    archive     = [for category in local.eventhub_diag_log_categories : category if can(regex("(?i)archive", category))]
    operational = [for category in local.eventhub_diag_log_categories : category if can(regex("(?i)operational", category))]
    autoscale   = [for category in local.eventhub_diag_log_categories : category if can(regex("(?i)autoscale", category))]
    kafka       = [for category in local.eventhub_diag_log_categories : category if can(regex("(?i)kafka", category))]
  }

  eventhub_area_log_map = merge(
    {
      all  = local.eventhub_diag_log_categories
      logs = local.eventhub_diag_log_categories
    },
    {
      for area, categories in local.eventhub_area_log_map_raw :
      area => [for category in categories : category if contains(local.eventhub_diag_log_categories, category)]
    }
  )

  eventhub_area_metric_map = {
    all     = local.eventhub_diag_metric_categories
    metrics = local.eventhub_diag_metric_categories
  }

  diagnostic_settings_create = {
    for ds in var.diagnostic_settings : ds.name => ds
    if(
      (
        ds.log_categories != null ||
        ds.metric_categories != null
      )
      ? (
        length(ds.log_categories == null ? [] : ds.log_categories) +
        length(ds.metric_categories == null ? [] : ds.metric_categories)
      ) > 0
      : (
        ds.areas == null || length(ds.areas) > 0
      )
    )
  }

  diagnostic_settings_resolved = [
    for ds in var.diagnostic_settings : merge(ds, {
      areas = coalesce(ds.areas, ["all"])
      log_categories = ds.log_categories != null ? ds.log_categories : distinct(flatten([
        for area in coalesce(ds.areas, ["all"]) : lookup(local.eventhub_area_log_map, area, [])
      ]))
      metric_categories = ds.metric_categories != null ? ds.metric_categories : distinct(flatten([
        for area in coalesce(ds.areas, ["all"]) : lookup(local.eventhub_area_metric_map, area, [])
      ]))
    })
  ]

  diagnostic_settings_effective = [
    for ds in local.diagnostic_settings_resolved : ds
    if length(ds.log_categories) + length(ds.metric_categories) > 0
  ]

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

resource "azurerm_monitor_diagnostic_setting" "diagnostic_settings" {
  for_each = {
    for ds in local.diagnostic_settings_resolved : ds.name => ds
    if contains(keys(local.diagnostic_settings_create), ds.name)
  }

  name               = each.value.name
  target_resource_id = azurerm_eventhub_namespace.namespace.id

  log_analytics_workspace_id     = try(each.value.log_analytics_workspace_id, null)
  log_analytics_destination_type = try(each.value.log_analytics_destination_type, null)
  storage_account_id             = try(each.value.storage_account_id, null)
  eventhub_authorization_rule_id = try(each.value.eventhub_authorization_rule_id, null)
  eventhub_name                  = try(each.value.eventhub_name, null)

  lifecycle {
    precondition {
      condition     = length(each.value.log_categories) + length(each.value.metric_categories) > 0
      error_message = "Diagnostic setting \"${each.key}\" resolves to zero log/metric categories for this namespace."
    }
  }

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
