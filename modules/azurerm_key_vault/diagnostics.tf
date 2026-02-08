locals {
  key_vault_diagnostic_catalog = {
    log_categories      = toset(["AuditEvent", "AzurePolicyEvaluationDetails"])
    log_category_groups = toset(["allLogs"])
    metric_categories   = toset(["AllMetrics"])
  }

  diagnostic_area_map = {
    all = {
      log_categories      = local.key_vault_diagnostic_catalog.log_categories
      log_category_groups = toset([])
      metric_categories   = local.key_vault_diagnostic_catalog.metric_categories
    }
    logs = {
      log_categories      = local.key_vault_diagnostic_catalog.log_categories
      log_category_groups = toset([])
      metric_categories   = toset([])
    }
    metrics = {
      log_categories      = toset([])
      log_category_groups = toset([])
      metric_categories   = local.key_vault_diagnostic_catalog.metric_categories
    }
    audit = {
      log_categories      = toset(["AuditEvent"])
      log_category_groups = toset([])
      metric_categories   = toset([])
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
      resolved_log_categories = sort(distinct(concat(
        flatten([
          for area in ds.area_names : tolist(lookup(local.diagnostic_area_map, area, {
            log_categories      = toset([])
            log_category_groups = toset([])
            metric_categories   = toset([])
          }).log_categories)
        ]),
        ds.log_categories != null ? ds.log_categories : []
      )))

      resolved_log_category_groups = sort(distinct(concat(
        flatten([
          for area in ds.area_names : tolist(lookup(local.diagnostic_area_map, area, {
            log_categories      = toset([])
            log_category_groups = toset([])
            metric_categories   = toset([])
          }).log_category_groups)
        ]),
        ds.log_category_groups != null ? ds.log_category_groups : []
      )))

      resolved_metric_categories = sort(distinct(concat(
        flatten([
          for area in ds.area_names : tolist(lookup(local.diagnostic_area_map, area, {
            log_categories      = toset([])
            log_category_groups = toset([])
            metric_categories   = toset([])
          }).metric_categories)
        ]),
        ds.metric_categories != null ? ds.metric_categories : []
      )))
    })
  ]

  diagnostic_settings_for_each = {
    for ds in local.diagnostic_settings_resolved : ds.name => ds
    if length(ds.resolved_log_categories) + length(ds.resolved_metric_categories) + length(ds.resolved_log_category_groups) > 0
  }

  diagnostic_settings_skipped = [
    for ds in local.diagnostic_settings_resolved : {
      name                = ds.name
      log_categories      = ds.resolved_log_categories
      metric_categories   = ds.resolved_metric_categories
      log_category_groups = ds.resolved_log_category_groups
      areas               = ds.area_names
    }
    if length(ds.resolved_log_categories) + length(ds.resolved_metric_categories) + length(ds.resolved_log_category_groups) == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings" {
  for_each = local.diagnostic_settings_for_each

  name               = each.value.name
  target_resource_id = azurerm_key_vault.key_vault.id

  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name
  partner_solution_id            = each.value.partner_solution_id

  dynamic "enabled_log" {
    for_each = each.value.resolved_log_categories
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = each.value.resolved_log_category_groups
    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = each.value.resolved_metric_categories
    content {
      category = enabled_metric.value
    }
  }
}
