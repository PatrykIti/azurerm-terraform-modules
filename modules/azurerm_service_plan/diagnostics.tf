resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_settings" {
  for_each = {
    for diagnostic_setting in var.diagnostic_settings : diagnostic_setting.name => diagnostic_setting
    if(
      (diagnostic_setting.log_categories != null && length(diagnostic_setting.log_categories) > 0) ||
      (diagnostic_setting.metric_categories != null && length(diagnostic_setting.metric_categories) > 0)
    )
  }

  name               = each.value.name
  target_resource_id = azurerm_service_plan.service_plan.id

  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name
  partner_solution_id            = each.value.partner_solution_id

  dynamic "enabled_metric" {
    for_each = each.value.metric_categories != null ? each.value.metric_categories : []
    content {
      category = enabled_metric.value
    }
  }
}
