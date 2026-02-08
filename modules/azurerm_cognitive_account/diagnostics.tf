resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  for_each = {
    for ds in var.diagnostic_settings : ds.name => ds
    if length(coalesce(ds.log_categories, [])) + length(coalesce(ds.log_category_groups, [])) + length(coalesce(ds.metric_categories, [])) > 0
  }

  name               = each.value.name
  target_resource_id = azurerm_cognitive_account.cognitive_account.id

  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name

  dynamic "enabled_log" {
    for_each = concat(
      [for category in(coalesce(each.value.log_categories, [])) : {
        category       = category
        category_group = null
      }],
      [for group in(coalesce(each.value.log_category_groups, [])) : {
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
    for_each = toset(coalesce(each.value.metric_categories, []))
    content {
      category = enabled_metric.value
    }
  }
}
