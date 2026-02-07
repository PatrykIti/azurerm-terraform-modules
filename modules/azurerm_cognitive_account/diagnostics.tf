data "azurerm_monitor_diagnostic_categories" "cognitive_account" {
  count       = length(var.diagnostic_settings) > 0 ? 1 : 0
  resource_id = azurerm_cognitive_account.cognitive_account.id
}

locals {
  diagnostic_log_categories    = tolist(try(data.azurerm_monitor_diagnostic_categories.cognitive_account[0].log_category_types, []))
  diagnostic_log_groups        = tolist(try(data.azurerm_monitor_diagnostic_categories.cognitive_account[0].log_category_groups, []))
  diagnostic_metric_categories = tolist(try(data.azurerm_monitor_diagnostic_categories.cognitive_account[0].metrics, []))

  diagnostic_settings_create = {
    for ds in var.diagnostic_settings : ds.name => ds
    if(
      (
        ds.log_categories != null ||
        ds.metric_categories != null ||
        ds.log_category_groups != null
      )
      ? (
        length(ds.log_categories == null ? [] : ds.log_categories) +
        length(ds.metric_categories == null ? [] : ds.metric_categories) +
        length(ds.log_category_groups == null ? [] : ds.log_category_groups)
      ) > 0
      : (
        ds.areas == null || length(ds.areas) > 0
      )
    )
  }

  diagnostic_settings_expanded = [
    for ds in var.diagnostic_settings : merge(ds, {
      areas = ds.areas == null ? ["all"] : [for area in ds.areas : lower(area)]
    })
  ]

  diagnostic_settings_resolved = [
    for ds in local.diagnostic_settings_expanded : merge(ds, {
      log_categories = ds.log_categories != null ? ds.log_categories : distinct(compact(concat(
        contains(ds.areas, "all") || contains(ds.areas, "logs") ? local.diagnostic_log_categories : []
      )))
      metric_categories = ds.metric_categories != null ? ds.metric_categories : distinct(compact(concat(
        contains(ds.areas, "all") || contains(ds.areas, "metrics") ? local.diagnostic_metric_categories : []
      )))
      log_category_groups = ds.log_category_groups != null ? ds.log_category_groups : distinct(compact([
        for area in ds.areas : area
        if !contains(["all", "logs", "metrics"], area) && contains(local.diagnostic_log_groups, area)
      ]))
    })
  ]

  diagnostic_settings_signal_counts = {
    for ds in local.diagnostic_settings_resolved : ds.name => (
      (ds.log_categories == null ? 0 : length(ds.log_categories)) +
      (ds.metric_categories == null ? 0 : length(ds.metric_categories)) +
      (ds.log_category_groups == null ? 0 : length(ds.log_category_groups))
    )
  }

  monitoring_for_each = {
    for ds in local.diagnostic_settings_resolved : ds.name => ds
    if contains(keys(local.diagnostic_settings_create), ds.name)
  }

  diagnostic_settings_skipped = [
    for ds in local.diagnostic_settings_resolved : {
      name                = ds.name
      areas               = ds.areas
      log_categories      = ds.log_categories
      metric_categories   = ds.metric_categories
      log_category_groups = ds.log_category_groups
    }
    if local.diagnostic_settings_signal_counts[ds.name] == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  for_each = local.monitoring_for_each

  name               = each.value.name
  target_resource_id = azurerm_cognitive_account.cognitive_account.id

  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name

  lifecycle {
    precondition {
      condition = each.value.log_categories == null || alltrue([
        for category in each.value.log_categories : contains(local.diagnostic_log_categories, category)
      ])
      error_message = "Diagnostic setting \"${each.key}\" contains unsupported log_categories for this Cognitive Account."
    }

    precondition {
      condition = each.value.metric_categories == null || alltrue([
        for category in each.value.metric_categories : contains(local.diagnostic_metric_categories, category)
      ])
      error_message = "Diagnostic setting \"${each.key}\" contains unsupported metric_categories for this Cognitive Account."
    }

    precondition {
      condition = each.value.log_category_groups == null || alltrue([
        for group in each.value.log_category_groups : contains(local.diagnostic_log_groups, group)
      ])
      error_message = "Diagnostic setting \"${each.key}\" contains unsupported log_category_groups for this Cognitive Account."
    }
  }

  dynamic "enabled_log" {
    for_each = concat(
      [for category in(each.value.log_categories == null ? [] : each.value.log_categories) : {
        category       = category
        category_group = null
      }],
      [for group in(each.value.log_category_groups == null ? [] : each.value.log_category_groups) : {
        category       = null
        category_group = group
      }]
    )

    content {
      category       = enabled_log.value.category
      category_group = enabled_log.value.category_group
    }
  }

  dynamic "enabled_metric" {
    for_each = each.value.metric_categories != null ? each.value.metric_categories : []
    content {
      category = enabled_metric.value
    }
  }
}
