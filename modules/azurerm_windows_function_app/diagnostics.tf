resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  for_each = {
    for ds in var.diagnostic_settings : ds.name => ds
    if(
      length(coalesce(ds.log_categories, [])) > 0 ||
      length(coalesce(ds.log_category_groups, [])) > 0 ||
      length(coalesce(ds.metric_categories, [])) > 0
    )
  }

  name               = each.value.name
  target_resource_id = azurerm_windows_function_app.windows_function_app.id

  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name
  partner_solution_id            = each.value.partner_solution_id

  dynamic "enabled_log" {
    for_each = concat(
      [
        for category in coalesce(each.value.log_categories, []) : {
          category       = category
          category_group = null
        }
      ],
      [
        for category_group in coalesce(each.value.log_category_groups, []) : {
          category       = null
          category_group = category_group
        }
      ]
    )
    content {
      category       = enabled_log.value.category
      category_group = enabled_log.value.category_group
    }
  }

  dynamic "enabled_metric" {
    for_each = coalesce(each.value.metric_categories, [])
    content {
      category = enabled_metric.value
    }
  }
}
