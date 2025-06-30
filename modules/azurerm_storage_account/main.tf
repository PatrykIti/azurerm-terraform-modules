resource "azurerm_storage_account" "storage_account" {

  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  # Security settings
  https_traffic_only_enabled      = var.security_settings.https_traffic_only_enabled
  min_tls_version                 = var.security_settings.min_tls_version
  shared_access_key_enabled       = var.security_settings.shared_access_key_enabled
  allow_nested_items_to_be_public = var.security_settings.allow_nested_items_to_be_public
  
  # Infrastructure encryption
  infrastructure_encryption_enabled = var.encryption.infrastructure_encryption_enabled

  # Blob properties
  dynamic "blob_properties" {
    for_each = var.account_kind != "FileStorage" ? [1] : []
    content {
      versioning_enabled       = var.blob_properties.versioning_enabled
      change_feed_enabled      = var.blob_properties.change_feed_enabled
      last_access_time_enabled = var.blob_properties.last_access_time_enabled
      default_service_version  = var.blob_properties.default_service_version

      dynamic "delete_retention_policy" {
        for_each = var.blob_properties.delete_retention_policy.enabled ? [1] : []
        content {
          days = var.blob_properties.delete_retention_policy.days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = var.blob_properties.container_delete_retention_policy.enabled ? [1] : []
        content {
          days = var.blob_properties.container_delete_retention_policy.days
        }
      }

      dynamic "cors_rule" {
        for_each = var.blob_properties.cors_rules
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
    }
  }

  # Network rules
  dynamic "network_rules" {
    for_each = var.network_rules.default_action != null ? [1] : []
    content {
      default_action             = var.network_rules.default_action
      bypass                     = var.network_rules.bypass
      ip_rules                   = var.network_rules.ip_rules
      virtual_network_subnet_ids = var.network_rules.virtual_network_subnet_ids
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.identity.type != null ? [1] : []
    content {
      type         = var.identity.type
      identity_ids = var.identity.type == "UserAssigned" || var.identity.type == "SystemAssigned, UserAssigned" ? var.identity.identity_ids : null
    }
  }

  # Customer managed key encryption
  dynamic "customer_managed_key" {
    for_each = var.encryption.enabled && var.encryption.key_vault_key_id != null ? [1] : []
    content {
      key_vault_key_id          = var.encryption.key_vault_key_id
      user_assigned_identity_id = var.encryption.user_assigned_identity_id
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
}

# Lifecycle management
resource "azurerm_storage_management_policy" "storage_management_policy" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  storage_account_id = azurerm_storage_account.storage_account.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      name    = rule.value.name
      enabled = rule.value.enabled

      filters {
        blob_types   = rule.value.filters.blob_types
        prefix_match = rule.value.filters.prefix_match
      }

      actions {
        dynamic "base_blob" {
          for_each = rule.value.actions.base_blob != null ? [rule.value.actions.base_blob] : []
          content {
            tier_to_cool_after_days_since_modification_greater_than        = base_blob.value.tier_to_cool_after_days_since_modification_greater_than
            tier_to_archive_after_days_since_modification_greater_than     = base_blob.value.tier_to_archive_after_days_since_modification_greater_than
            delete_after_days_since_modification_greater_than              = base_blob.value.delete_after_days_since_modification_greater_than
            tier_to_cool_after_days_since_last_access_time_greater_than    = base_blob.value.tier_to_cool_after_days_since_last_access_time_greater_than
            tier_to_archive_after_days_since_last_access_time_greater_than = base_blob.value.tier_to_archive_after_days_since_last_access_time_greater_than
            delete_after_days_since_last_access_time_greater_than          = base_blob.value.delete_after_days_since_last_access_time_greater_than
          }
        }

        dynamic "snapshot" {
          for_each = rule.value.actions.snapshot != null ? [rule.value.actions.snapshot] : []
          content {
            change_tier_to_archive_after_days_since_creation = snapshot.value.change_tier_to_archive_after_days_since_creation
            change_tier_to_cool_after_days_since_creation    = snapshot.value.change_tier_to_cool_after_days_since_creation
            delete_after_days_since_creation_greater_than    = snapshot.value.delete_after_days_since_creation_greater_than
          }
        }

        dynamic "version" {
          for_each = rule.value.actions.version != null ? [rule.value.actions.version] : []
          content {
            change_tier_to_archive_after_days_since_creation = version.value.change_tier_to_archive_after_days_since_creation
            change_tier_to_cool_after_days_since_creation    = version.value.change_tier_to_cool_after_days_since_creation
            delete_after_days_since_creation                 = version.value.delete_after_days_since_creation
          }
        }
      }
    }
  }
}

# Private endpoints
resource "azurerm_private_endpoint" "private_endpoint" {
  for_each = { for idx, pe in var.private_endpoints : pe.name => pe }

  name                = "${var.name}-pe-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = coalesce(each.value.private_service_connection_name, "${var.name}-psc-${each.key}")
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    is_manual_connection           = each.value.is_manual_connection
    subresource_names              = each.value.subresource_names
    request_message                = each.value.is_manual_connection ? each.value.request_message : null
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = each.value.private_dns_zone_group_name
      private_dns_zone_ids = each.value.private_dns_zone_ids
    }
  }

  custom_network_interface_name = each.value.custom_network_interface_name
  tags                          = merge(var.tags, each.value.tags)
}

# Diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  count = var.diagnostic_settings.enabled ? 1 : 0

  name                           = "${var.name}-diag"
  target_resource_id             = azurerm_storage_account.storage_account.id
  log_analytics_workspace_id     = var.diagnostic_settings.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_settings.storage_account_id
  eventhub_authorization_rule_id = var.diagnostic_settings.eventhub_auth_rule_id

  dynamic "enabled_log" {
    for_each = {
      for k, v in {
        "StorageRead"   = var.diagnostic_settings.logs.storage_read
        "StorageWrite"  = var.diagnostic_settings.logs.storage_write
        "StorageDelete" = var.diagnostic_settings.logs.storage_delete
      } : k => v if v
    }
    content {
      category = enabled_log.key
    }
  }

  dynamic "metric" {
    for_each = {
      for k, v in {
        "Transaction" = var.diagnostic_settings.metrics.transaction
        "Capacity"    = var.diagnostic_settings.metrics.capacity
      } : k => v if v
    }
    content {
      category = metric.key
    }
  }
}

# Blob service diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "blob_diagnostic_setting" {
  count = var.diagnostic_settings.enabled && var.account_kind != "FileStorage" ? 1 : 0

  name                           = "${var.name}-blob-diag"
  target_resource_id             = "${azurerm_storage_account.storage_account.id}/blobServices/default"
  log_analytics_workspace_id     = var.diagnostic_settings.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_settings.storage_account_id
  eventhub_authorization_rule_id = var.diagnostic_settings.eventhub_auth_rule_id

  dynamic "enabled_log" {
    for_each = {
      for k, v in {
        "StorageRead"   = var.diagnostic_settings.logs.storage_read
        "StorageWrite"  = var.diagnostic_settings.logs.storage_write
        "StorageDelete" = var.diagnostic_settings.logs.storage_delete
      } : k => v if v
    }
    content {
      category = enabled_log.key
    }
  }

  dynamic "metric" {
    for_each = {
      for k, v in {
        "Transaction" = var.diagnostic_settings.metrics.transaction
        "Capacity"    = var.diagnostic_settings.metrics.capacity
      } : k => v if v
    }
    content {
      category = metric.key
    }
  }
}

# Storage Containers
resource "azurerm_storage_container" "storage_container" {
  for_each = { for c in var.containers : c.name => c }

  name                  = each.value.name
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = each.value.container_access_type
  metadata             = each.value.metadata
}

# Storage Queues
resource "azurerm_storage_queue" "storage_queue" {
  for_each = { for q in var.queues : q.name => q }

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.storage_account.name
  metadata            = each.value.metadata
}

# Storage Tables
resource "azurerm_storage_table" "storage_table" {
  for_each = { for t in var.tables : t.name => t }

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.storage_account.name
}

# File Shares
resource "azurerm_storage_share" "storage_share" {
  for_each = { for fs in var.file_shares : fs.name => fs }

  name                 = each.value.name
  storage_account_id   = azurerm_storage_account.storage_account.id
  quota               = each.value.quota
  access_tier         = each.value.access_tier
  enabled_protocol    = each.value.enabled_protocol
  metadata            = each.value.metadata
}
