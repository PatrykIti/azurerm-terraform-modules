data "azurerm_monitor_diagnostic_categories" "bastion_host" {
  count       = length(var.diagnostic_settings) > 0 ? 1 : 0
  resource_id = azurerm_bastion_host.bastion_host.id
}

locals {
  bastion_diag_log_categories    = try(data.azurerm_monitor_diagnostic_categories.bastion_host[0].log_category_types, [])
  bastion_diag_metric_categories = try(data.azurerm_monitor_diagnostic_categories.bastion_host[0].metrics, [])

  bastion_area_log_map_raw = {
    audit = ["BastionAuditLogs"]
  }

  bastion_area_log_map = merge(
    {
      all  = local.bastion_diag_log_categories
      logs = local.bastion_diag_log_categories
    },
    {
      for area, categories in local.bastion_area_log_map_raw :
      area => [for category in categories : category if contains(local.bastion_diag_log_categories, category)]
    }
  )

  bastion_area_metric_map = {
    all     = local.bastion_diag_metric_categories
    metrics = local.bastion_diag_metric_categories
  }

  diagnostic_settings_resolved = [
    for ds in var.diagnostic_settings : merge(ds, {
      areas = coalesce(ds.areas, ["all"])
      log_categories = ds.log_categories != null ? ds.log_categories : distinct(flatten([
        for area in coalesce(ds.areas, ["all"]) : lookup(local.bastion_area_log_map, area, [])
      ]))
      metric_categories = ds.metric_categories != null ? ds.metric_categories : distinct(flatten([
        for area in coalesce(ds.areas, ["all"]) : lookup(local.bastion_area_metric_map, area, [])
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

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings" {
  for_each = {
    for ds in local.diagnostic_settings_effective : ds.name => ds
  }

  name               = each.value.name
  target_resource_id = azurerm_bastion_host.bastion_host.id

  log_analytics_workspace_id     = try(each.value.log_analytics_workspace_id, null)
  log_analytics_destination_type = try(each.value.log_analytics_destination_type, null)
  storage_account_id             = try(each.value.storage_account_id, null)
  eventhub_authorization_rule_id = try(each.value.eventhub_authorization_rule_id, null)
  eventhub_name                  = try(each.value.eventhub_name, null)

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
