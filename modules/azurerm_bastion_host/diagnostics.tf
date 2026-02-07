locals {
  bastion_area_map = {
    all = {
      log_categories      = []
      log_category_groups = ["allLogs"]
      metric_categories   = ["AllMetrics"]
    }
    logs = {
      log_categories      = []
      log_category_groups = ["allLogs"]
      metric_categories   = []
    }
    metrics = {
      log_categories      = []
      log_category_groups = []
      metric_categories   = ["AllMetrics"]
    }
    audit = {
      log_categories      = ["BastionAuditLogs"]
      log_category_groups = []
      metric_categories   = []
    }
  }

  diagnostic_settings_expanded = [
    for ds in var.diagnostic_settings : merge(ds, {
      area_names = ds.areas != null ? ds.areas : (
        ds.log_categories == null && ds.metric_categories == null && ds.log_category_groups == null ? ["all"] : []
      )
    })
  ]

  diagnostic_settings_resolved = [
    for ds in local.diagnostic_settings_expanded : merge(ds, {
      log_categories = sort(distinct(concat(
        flatten([
          for area in ds.area_names : lookup(local.bastion_area_map, area, {
            log_categories      = []
            log_category_groups = []
            metric_categories   = []
          }).log_categories
        ]),
        ds.log_categories != null ? ds.log_categories : []
      )))

      log_category_groups = sort(distinct(concat(
        flatten([
          for area in ds.area_names : lookup(local.bastion_area_map, area, {
            log_categories      = []
            log_category_groups = []
            metric_categories   = []
          }).log_category_groups
        ]),
        ds.log_category_groups != null ? ds.log_category_groups : []
      )))

      metric_categories = sort(distinct(concat(
        flatten([
          for area in ds.area_names : lookup(local.bastion_area_map, area, {
            log_categories      = []
            log_category_groups = []
            metric_categories   = []
          }).metric_categories
        ]),
        ds.metric_categories != null ? ds.metric_categories : []
      )))
    })
  ]

  diagnostic_settings_skipped = [
    for ds in local.diagnostic_settings_resolved : {
      name                = ds.name
      areas               = ds.area_names
      log_categories      = ds.log_categories
      log_category_groups = ds.log_category_groups
      metric_categories   = ds.metric_categories
    }
    if length(ds.log_categories) + length(ds.log_category_groups) + length(ds.metric_categories) == 0
  ]

  diagnostic_settings_for_each = {
    for ds in local.diagnostic_settings_resolved : ds.name => ds
    if length(ds.log_categories) + length(ds.log_category_groups) + length(ds.metric_categories) > 0
  }
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings" {
  for_each = local.diagnostic_settings_for_each

  name               = each.value.name
  target_resource_id = azurerm_bastion_host.bastion_host.id

  log_analytics_workspace_id     = try(each.value.log_analytics_workspace_id, null)
  log_analytics_destination_type = try(each.value.log_analytics_destination_type, null)
  storage_account_id             = try(each.value.storage_account_id, null)
  eventhub_authorization_rule_id = try(each.value.eventhub_authorization_rule_id, null)
  eventhub_name                  = try(each.value.eventhub_name, null)
  partner_solution_id            = try(each.value.partner_solution_id, null)

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = each.value.log_category_groups
    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = each.value.metric_categories
    content {
      category = enabled_metric.value
    }
  }
}
