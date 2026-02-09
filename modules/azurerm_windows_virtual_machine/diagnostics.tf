resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  for_each = {
    for ds in var.diagnostic_settings : ds.name => ds
    if length(coalesce(ds.log_categories, [])) + length(coalesce(ds.log_category_groups, [])) + length(coalesce(ds.metric_categories, [])) > 0
  }

  name               = each.value.name
  target_resource_id = azurerm_windows_virtual_machine.windows_virtual_machine.id

  log_analytics_workspace_id     = try(each.value.log_analytics_workspace_id, null)
  log_analytics_destination_type = try(each.value.log_analytics_destination_type, null)
  storage_account_id             = try(each.value.storage_account_id, null)
  eventhub_authorization_rule_id = try(each.value.eventhub_authorization_rule_id, null)
  eventhub_name                  = try(each.value.eventhub_name, null)

  dynamic "enabled_log" {
    for_each = toset(coalesce(each.value.log_categories, []))
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = toset(coalesce(each.value.log_category_groups, []))
    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(coalesce(each.value.metric_categories, []))
    content {
      category = enabled_metric.value
    }
  }
}
