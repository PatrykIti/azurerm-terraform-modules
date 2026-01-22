data "azurerm_monitor_diagnostic_categories" "postgresql_flexible_server" {
  count       = length(var.diagnostic_settings) > 0 ? 1 : 0
  resource_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id
}

locals {
  diagnostics_enabled = length(var.diagnostic_settings) > 0

  postgresql_diag_log_categories    = local.diagnostics_enabled ? data.azurerm_monitor_diagnostic_categories.postgresql_flexible_server[0].log_category_types : []
  postgresql_diag_metric_categories = local.diagnostics_enabled ? data.azurerm_monitor_diagnostic_categories.postgresql_flexible_server[0].metrics : []

  postgresql_area_log_map = {
    all  = local.postgresql_diag_log_categories
    logs = local.postgresql_diag_log_categories
  }

  postgresql_area_metric_map = {
    all     = local.postgresql_diag_metric_categories
    metrics = local.postgresql_diag_metric_categories
  }

  diagnostic_settings_resolved = [
    for ds in var.diagnostic_settings : merge(ds, {
      areas = ds.areas != null ? ds.areas : ["all"]
      log_categories = ds.log_categories != null ? ds.log_categories : distinct(flatten([
        for area in(ds.areas != null ? ds.areas : ["all"]) : lookup(local.postgresql_area_log_map, area, [])
      ]))
      metric_categories = ds.metric_categories != null ? ds.metric_categories : distinct(flatten([
        for area in(ds.areas != null ? ds.areas : ["all"]) : lookup(local.postgresql_area_metric_map, area, [])
      ]))
    })
  ]

  diagnostic_settings_resolved_by_name = {
    for ds in local.diagnostic_settings_resolved : ds.name => ds
  }

  diagnostic_settings_for_each = {
    for ds in var.diagnostic_settings : ds.name => ds
    if !(
      ds.log_categories != null && length(ds.log_categories) == 0 &&
      ds.metric_categories != null && length(ds.metric_categories) == 0
    )
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
  for_each = local.diagnostic_settings_for_each

  name               = each.value.name
  target_resource_id = azurerm_postgresql_flexible_server.postgresql_flexible_server.id

  log_analytics_workspace_id     = try(local.diagnostic_settings_resolved_by_name[each.key].log_analytics_workspace_id, null)
  log_analytics_destination_type = try(local.diagnostic_settings_resolved_by_name[each.key].log_analytics_destination_type, null)
  storage_account_id             = try(local.diagnostic_settings_resolved_by_name[each.key].storage_account_id, null)
  eventhub_authorization_rule_id = try(local.diagnostic_settings_resolved_by_name[each.key].eventhub_authorization_rule_id, null)
  eventhub_name                  = try(local.diagnostic_settings_resolved_by_name[each.key].eventhub_name, null)

  dynamic "enabled_log" {
    for_each = local.diagnostic_settings_resolved_by_name[each.key].log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = local.diagnostic_settings_resolved_by_name[each.key].metric_categories
    content {
      category = enabled_metric.value
    }
  }
}
