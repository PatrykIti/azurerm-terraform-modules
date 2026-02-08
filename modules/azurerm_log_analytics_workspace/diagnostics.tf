locals {
  diagnostic_settings_for_each = {
    for ds in var.diagnostic_settings : ds.name => {
      name                           = ds.name
      log_categories                 = ds.log_categories == null ? [] : [for c in ds.log_categories : trimspace(c)]
      log_category_groups            = ds.log_category_groups == null ? [] : [for c in ds.log_category_groups : trimspace(c)]
      metric_categories              = ds.metric_categories == null ? [] : [for c in ds.metric_categories : trimspace(c)]
      log_analytics_workspace_id     = ds.log_analytics_workspace_id == null ? null : trimspace(ds.log_analytics_workspace_id)
      log_analytics_destination_type = ds.log_analytics_destination_type == null ? null : trimspace(ds.log_analytics_destination_type)
      storage_account_id             = ds.storage_account_id == null ? null : trimspace(ds.storage_account_id)
      eventhub_authorization_rule_id = ds.eventhub_authorization_rule_id == null ? null : trimspace(ds.eventhub_authorization_rule_id)
      eventhub_name                  = ds.eventhub_name == null ? null : trimspace(ds.eventhub_name)
      partner_solution_id            = ds.partner_solution_id == null ? null : trimspace(ds.partner_solution_id)
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  for_each = local.diagnostic_settings_for_each

  name               = each.value.name
  target_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name
  partner_solution_id            = each.value.partner_solution_id

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
