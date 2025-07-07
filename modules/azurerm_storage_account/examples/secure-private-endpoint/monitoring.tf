# ==============================================================================
# Advanced Monitoring and Security Alerting
# ==============================================================================

# Action Group for Security Alerts
resource "azurerm_monitor_action_group" "security" {
  name                = "ag-security-alerts"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "sec-alerts"

  email_receiver {
    name          = "security-team"
    email_address = "security@example.com"
  }

  webhook_receiver {
    name        = "security-webhook"
    service_uri = "https://example.com/security/webhook"
  }

  tags = var.tags
}

# ==============================================================================
# Storage Account Security Alerts
# ==============================================================================

# Alert for Authentication Failures
resource "azurerm_monitor_metric_alert" "auth_failures" {
  name                = "alert-storage-auth-failures"
  resource_group_name = azurerm_resource_group.example.name
  scopes              = [module.secure_storage.id]
  description         = "Alert on storage authentication failures"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5

    dimension {
      name     = "ResponseType"
      operator = "Include"
      values   = ["AuthenticationFailed", "AuthorizationFailed"]
    }

    dimension {
      name     = "Authentication"
      operator = "Include"
      values   = ["OAuth", "SAS", "AccountKey"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.security.id
  }

  tags = merge(var.tags, {
    AlertType = "Security"
  })
}

# Alert for Anomalous Data Access
resource "azurerm_monitor_metric_alert" "anomalous_access" {
  name                = "alert-anomalous-data-access"
  resource_group_name = azurerm_resource_group.example.name
  scopes              = [module.secure_storage.id]
  description         = "Alert on unusual data access patterns"
  severity            = 2
  frequency           = "PT15M"
  window_size         = "PT1H"

  dynamic_criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Egress"
    aggregation      = "Total"
    operator         = "GreaterThan"
    alert_sensitivity = "High"

    dimension {
      name     = "GeoType"
      operator = "Include"
      values   = ["Primary", "Secondary"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.security.id
  }

  tags = merge(var.tags, {
    AlertType = "AnomalyDetection"
  })
}

# ==============================================================================
# Key Vault Monitoring
# ==============================================================================

# Diagnostic Settings for Key Vault
resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  count                      = var.enable_key_vault_monitoring ? 1 : 0
  name                       = "diag-keyvault"
  target_resource_id         = azurerm_key_vault.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Alert for Key Vault Access from Unknown IPs
resource "azurerm_monitor_scheduled_query_rules_alert" "kv_unknown_access" {
  count               = var.enable_key_vault_monitoring ? 1 : 0
  name                = "alert-kv-unknown-ip-access"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  action {
    action_group = [azurerm_monitor_action_group.security.id]
  }

  data_source_id = azurerm_log_analytics_workspace.example.id
  description    = "Alert when Key Vault is accessed from unknown IP addresses"
  enabled        = true

  query = <<-QUERY
    AzureDiagnostics
    | where ResourceType == "VAULTS" and Category == "AuditEvent"
    | where CallerIPAddress !in ("10.0.0.0/16") // Add your known IP ranges
    | where ResultType != "Success"
    | summarize Count = count() by CallerIPAddress, OperationName
    | where Count > 3
  QUERY

  severity    = 1
  frequency   = 5
  time_window = 15

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  tags = var.tags
}

# ==============================================================================
# Microsoft Defender for Storage (Advanced Threat Protection)
# ==============================================================================

resource "azurerm_security_center_storage_defender" "example" {
  count                          = var.enable_advanced_threat_protection ? 1 : 0
  storage_account_id             = module.secure_storage.id
  override_subscription_settings_enabled = true
  malware_scanning_on_upload_enabled    = true
  malware_scanning_on_upload_cap_gb_per_month = 5000
  sensitive_data_discovery_enabled      = true

  depends_on = [module.secure_storage]
}

# ==============================================================================
# Log Analytics Queries and Alerts
# ==============================================================================

# Saved Query for Failed Storage Operations
resource "azurerm_log_analytics_saved_search" "storage_failures" {
  name                       = "StorageOperationFailures"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  category                   = "Security"
  display_name               = "Storage Operation Failures"
  query                      = <<-QUERY
    StorageBlobLogs
    | where StatusCode >= 400
    | where AccountName == "${module.secure_storage.name}"
    | summarize FailureCount = count() by bin(TimeGenerated, 5m), StatusCode, StatusText, OperationName
    | where FailureCount > 10
    | order by TimeGenerated desc
  QUERY

  tags = var.tags
}

# Saved Query for Data Exfiltration Detection
resource "azurerm_log_analytics_saved_search" "data_exfiltration" {
  name                       = "DataExfiltrationDetection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  category                   = "Security"
  display_name               = "Potential Data Exfiltration"
  query                      = <<-QUERY
    StorageBlobLogs
    | where AccountName == "${module.secure_storage.name}"
    | where OperationName == "GetBlob"
    | summarize TotalBytesTransferred = sum(ResponseBodySize) by bin(TimeGenerated, 1h), CallerIpAddress
    | where TotalBytesTransferred > 1073741824 // 1GB
    | order by TotalBytesTransferred desc
  QUERY

  tags = var.tags
}

# ==============================================================================
# Azure Monitor Workbook for Security Dashboard
# ==============================================================================

resource "azurerm_application_insights" "security" {
  name                = "appi-security-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example.id
  application_type    = "other"

  tags = merge(var.tags, {
    Purpose = "SecurityMonitoring"
  })
}