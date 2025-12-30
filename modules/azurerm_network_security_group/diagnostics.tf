data "azurerm_monitor_diagnostic_categories" "network_security_group" {
  count       = length(var.diagnostic_settings) > 0 ? 1 : 0
  resource_id = azurerm_network_security_group.network_security_group.id
}

locals {
  # Whether any diagnostic settings are configured for this NSG.
  diagnostics_enabled = length(var.diagnostic_settings) > 0

  # All available log categories returned by Azure for this NSG resource.
  nsg_diag_log_categories = local.diagnostics_enabled ? data.azurerm_monitor_diagnostic_categories.network_security_group[0].log_category_types : []

  # All available metric categories returned by Azure for this NSG resource.
  nsg_diag_metric_categories = local.diagnostics_enabled ? data.azurerm_monitor_diagnostic_categories.network_security_group[0].metrics : []

  # Raw area-to-log mapping before filtering for availability.
  nsg_area_log_map_raw = {
    event        = ["NetworkSecurityGroupEvent"]
    rule_counter = ["NetworkSecurityGroupRuleCounter"]
  }

  # Area-to-log mapping, filtered to categories that exist in the current region/version.
  nsg_area_log_map = merge(
    { all = local.nsg_diag_log_categories },
    { logs = local.nsg_diag_log_categories },
    { for k, v in local.nsg_area_log_map_raw : k => [for c in v : c if contains(local.nsg_diag_log_categories, c)] }
  )

  # Area-to-metric mapping; metrics are typically AllMetrics when available.
  nsg_area_metric_map = {
    all     = local.nsg_diag_metric_categories
    metrics = local.nsg_diag_metric_categories
  }

  # Resolved settings with categories derived from areas unless explicitly provided.
  diagnostic_settings_resolved = [
    for ds in var.diagnostic_settings : merge(ds, {
      areas = ds.areas != null ? ds.areas : ["all"]
      log_categories = ds.log_categories != null ? ds.log_categories : distinct(flatten([
        for area in(ds.areas != null ? ds.areas : ["all"]) : lookup(local.nsg_area_log_map, area, [])
      ]))
      metric_categories = ds.metric_categories != null ? ds.metric_categories : distinct(flatten([
        for area in(ds.areas != null ? ds.areas : ["all"]) : lookup(local.nsg_area_metric_map, area, [])
      ]))
    })
  ]

  # Map resolved settings by name for easy lookup in resources.
  diagnostic_settings_resolved_by_name = {
    for ds in local.diagnostic_settings_resolved : ds.name => ds
  }

  # Skip only entries that explicitly set both categories lists to empty.
  diagnostic_settings_for_each = {
    for ds in var.diagnostic_settings : ds.name => ds
    if !(
      ds.log_categories != null && length(ds.log_categories) == 0 &&
      ds.metric_categories != null && length(ds.metric_categories) == 0
    )
  }

  # Entries skipped due to having zero categories after filtering.
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
  for_each           = local.diagnostic_settings_for_each
  name               = each.value.name
  target_resource_id = azurerm_network_security_group.network_security_group.id

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

  dynamic "metric" {
    for_each = local.diagnostic_settings_resolved_by_name[each.key].metric_categories
    content {
      category = metric.value
      enabled  = true
    }
  }
}
