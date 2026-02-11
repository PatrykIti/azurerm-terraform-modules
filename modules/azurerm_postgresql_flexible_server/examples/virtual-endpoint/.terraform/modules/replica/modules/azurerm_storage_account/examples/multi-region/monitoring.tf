# ==============================================================================
# Monitoring and Alerting for Multi-Region Storage
# ==============================================================================

# Action Group for Alerts
resource "azurerm_monitor_action_group" "replication" {
  count               = var.enable_monitoring_alerts ? 1 : 0
  name                = "ag-replication-alerts"
  resource_group_name = azurerm_resource_group.primary.name
  short_name          = "repl-alerts"

  email_receiver {
    name          = "admin-email"
    email_address = "storage-admin@example.com"
  }

  # Webhook for integration with incident management
  webhook_receiver {
    name        = "incident-webhook"
    service_uri = "https://example.com/webhook/incidents"
  }

  tags = var.tags
}

# ==============================================================================
# Replication Lag Alerts
# ==============================================================================

# Metric Alert for Primary Storage Replication Lag
resource "azurerm_monitor_metric_alert" "primary_replication_lag" {
  count               = var.enable_monitoring_alerts ? 1 : 0
  name                = "alert-primary-replication-lag"
  resource_group_name = azurerm_resource_group.primary.name
  scopes              = [module.primary_storage.id]
  description         = "Alert when geo-replication lag exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "GeoReplicationLatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.replication_lag_threshold_minutes * 60000 # Convert to milliseconds
  }

  action {
    action_group_id = azurerm_monitor_action_group.replication[0].id
  }

  tags = merge(var.tags, {
    AlertType = "ReplicationLag"
    Storage   = module.primary_storage.name
  })
}

# ==============================================================================
# Availability Alerts
# ==============================================================================

# Alert for Primary Storage Availability
resource "azurerm_monitor_metric_alert" "primary_availability" {
  count               = var.enable_monitoring_alerts ? 1 : 0
  name                = "alert-primary-availability"
  resource_group_name = azurerm_resource_group.primary.name
  scopes              = [module.primary_storage.id]
  description         = "Alert when storage availability drops below 99.9%"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 99.9
  }

  action {
    action_group_id = azurerm_monitor_action_group.replication[0].id
  }

  tags = merge(var.tags, {
    AlertType = "Availability"
    Storage   = module.primary_storage.name
  })
}

# Alert for Secondary Storage Availability
resource "azurerm_monitor_metric_alert" "secondary_availability" {
  count               = var.enable_monitoring_alerts ? 1 : 0
  name                = "alert-secondary-availability"
  resource_group_name = azurerm_resource_group.secondary.name
  scopes              = [module.secondary_storage.id]
  description         = "Alert when storage availability drops below 99.9%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 99.9
  }

  action {
    action_group_id = azurerm_monitor_action_group.replication[0].id
  }

  tags = merge(var.tags, {
    AlertType = "Availability"
    Storage   = module.secondary_storage.name
  })
}

# ==============================================================================
# Transaction Error Alerts
# ==============================================================================

# Alert for Primary Storage Transaction Errors
resource "azurerm_monitor_metric_alert" "primary_errors" {
  count               = var.enable_monitoring_alerts ? 1 : 0
  name                = "alert-primary-transaction-errors"
  resource_group_name = azurerm_resource_group.primary.name
  scopes              = [module.primary_storage.id]
  description         = "Alert on high transaction error rate"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 100

    dimension {
      name     = "ResponseType"
      operator = "Include"
      values   = ["ServerOtherError", "ServerTimeoutError", "ClientOtherError"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.replication[0].id
  }

  tags = merge(var.tags, {
    AlertType = "TransactionErrors"
    Storage   = module.primary_storage.name
  })
}

# ==============================================================================
# Capacity Alerts
# ==============================================================================

# Alert for Storage Capacity
resource "azurerm_monitor_metric_alert" "capacity_alert" {
  count               = var.enable_monitoring_alerts ? 1 : 0
  name                = "alert-storage-capacity"
  resource_group_name = azurerm_resource_group.primary.name
  scopes              = [module.primary_storage.id]
  description         = "Alert when storage capacity exceeds 80%"
  severity            = 3
  frequency           = "PT1H"
  window_size         = "PT6H"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 8796093022208 # 8TB (80% of 10TB)
  }

  action {
    action_group_id = azurerm_monitor_action_group.replication[0].id
  }

  tags = merge(var.tags, {
    AlertType = "Capacity"
    Storage   = module.primary_storage.name
  })
}

# ==============================================================================
# Replication Health Dashboard
# ==============================================================================

# Application Insights for Monitoring Dashboard
resource "azurerm_application_insights" "replication" {
  count               = var.enable_monitoring_alerts ? 1 : 0
  name                = "appi-replication-example"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  workspace_id        = azurerm_log_analytics_workspace.shared.id
  application_type    = "other"

  tags = merge(var.tags, {
    Purpose = "ReplicationMonitoring"
  })
}

# ==============================================================================
# Log Analytics Queries for Replication Monitoring
# ==============================================================================

# Saved Query for Replication Lag Analysis
resource "azurerm_log_analytics_saved_search" "replication_lag" {
  count                      = var.enable_monitoring_alerts ? 1 : 0
  name                       = "ReplicationLagAnalysis"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.shared.id
  category                   = "Replication"
  display_name               = "Storage Replication Lag Analysis"
  query                      = <<-QUERY
    AzureMetrics
    | where ResourceProvider == "MICROSOFT.STORAGE"
    | where MetricName == "GeoReplicationLatency"
    | summarize AvgLag = avg(Average), MaxLag = max(Maximum) by bin(TimeGenerated, 5m), Resource
    | where MaxLag > ${var.replication_lag_threshold_minutes * 60000}
    | order by TimeGenerated desc
  QUERY

  tags = var.tags
}

# Saved Query for Storage Errors
resource "azurerm_log_analytics_saved_search" "storage_errors" {
  count                      = var.enable_monitoring_alerts ? 1 : 0
  name                       = "StorageErrorAnalysis"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.shared.id
  category                   = "Errors"
  display_name               = "Storage Error Analysis"
  query                      = <<-QUERY
    StorageBlobLogs
    | where StatusCode >= 400
    | summarize ErrorCount = count() by bin(TimeGenerated, 5m), StatusCode, StatusText, Resource
    | order by TimeGenerated desc, ErrorCount desc
  QUERY

  tags = var.tags
}
