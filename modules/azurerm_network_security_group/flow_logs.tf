locals {
  # Whether flow log is configured.
  flow_log_enabled = var.flow_log != null

  # Effective flow log name (defaults to "<nsg-name>-flow-log").
  flow_log_name = local.flow_log_enabled ? (
    try(var.flow_log.name, null) != null && try(var.flow_log.name, "") != "" ? var.flow_log.name : "${var.name}-flow-log"
  ) : null

  # Retention policy config if provided.
  flow_log_retention_policy = local.flow_log_enabled ? try(var.flow_log.retention_policy, null) : null

  # Traffic analytics config if provided.
  flow_log_traffic_analytics = local.flow_log_enabled ? try(var.flow_log.traffic_analytics, null) : null
}

resource "azurerm_network_watcher_flow_log" "network_watcher_flow_log" {
  count                     = local.flow_log_enabled ? 1 : 0
  name                      = local.flow_log_name
  network_watcher_name      = try(var.flow_log.network_watcher_name, null)
  resource_group_name       = try(var.flow_log.network_watcher_resource_group_name, null)
  network_security_group_id = azurerm_network_security_group.network_security_group.id
  storage_account_id        = try(var.flow_log.storage_account_id, null)
  enabled                   = try(var.flow_log.enabled, true)
  version                   = try(var.flow_log.version, 2)

  dynamic "retention_policy" {
    for_each = local.flow_log_retention_policy == null ? [] : [local.flow_log_retention_policy]
    content {
      enabled = try(retention_policy.value.enabled, false)
      days    = try(retention_policy.value.days, 0)
    }
  }

  dynamic "traffic_analytics" {
    for_each = local.flow_log_traffic_analytics == null ? [] : [local.flow_log_traffic_analytics]
    content {
      enabled               = try(traffic_analytics.value.enabled, true)
      workspace_id          = traffic_analytics.value.workspace_id
      workspace_region      = traffic_analytics.value.workspace_region
      workspace_resource_id = traffic_analytics.value.workspace_resource_id
      interval_in_minutes   = try(traffic_analytics.value.interval_in_minutes, 10)
    }
  }
}
