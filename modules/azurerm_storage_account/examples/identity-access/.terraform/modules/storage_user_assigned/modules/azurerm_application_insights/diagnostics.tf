locals {
  monitoring_for_each = {
    for ds in var.monitoring : ds.name => ds
    if(
      (ds.log_categories != null && length(ds.log_categories) > 0) ||
      (ds.metric_categories != null && length(ds.metric_categories) > 0)
    )
  }

  diagnostic_settings_skipped = [
    for ds in var.monitoring : {
      name              = ds.name
      log_categories    = ds.log_categories
      metric_categories = ds.metric_categories
    }
    if(
      (ds.log_categories == null ? 0 : length(ds.log_categories)) +
      (ds.metric_categories == null ? 0 : length(ds.metric_categories))
    ) == 0
  ]
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings" {
  for_each = local.monitoring_for_each

  name               = each.value.name
  target_resource_id = azurerm_application_insights.application_insights.id

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
