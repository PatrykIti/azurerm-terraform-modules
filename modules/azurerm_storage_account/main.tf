# Azure Storage Account Module - Initial Release
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

  # Encryption key types
  queue_encryption_key_type = var.queue_encryption_key_type
  table_encryption_key_type = var.table_encryption_key_type

  # Additional security controls
  cross_tenant_replication_enabled = var.cross_tenant_replication_enabled
  default_to_oauth_authentication  = var.default_to_oauth_authentication
  allowed_copy_scope               = var.allowed_copy_scope
  public_network_access_enabled    = var.security_settings.public_network_access_enabled

  # Infrastructure parameters
  large_file_share_enabled = var.large_file_share_enabled
  edge_zone                = var.edge_zone

  # Data Lake Gen2 and Protocol Support
  is_hns_enabled     = var.is_hns_enabled
  sftp_enabled       = var.sftp_enabled
  nfsv3_enabled      = var.nfsv3_enabled
  local_user_enabled = var.local_user_enabled

  # Blob properties
  dynamic "blob_properties" {
    for_each = var.account_kind != "FileStorage" ? [1] : []
    content {
      versioning_enabled            = var.blob_properties.versioning_enabled
      change_feed_enabled           = var.blob_properties.change_feed_enabled
      change_feed_retention_in_days = try(var.blob_properties.change_feed_retention_in_days, null)
      last_access_time_enabled      = var.blob_properties.last_access_time_enabled
      default_service_version       = var.blob_properties.default_service_version

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

      dynamic "restore_policy" {
        for_each = try(var.blob_properties.restore_policy, null) != null ? [var.blob_properties.restore_policy] : []
        content {
          days = restore_policy.value.days
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

  # Share properties
  dynamic "share_properties" {
    for_each = var.share_properties != null ? [var.share_properties] : []
    content {
      # CORS rules
      dynamic "cors_rule" {
        for_each = share_properties.value.cors_rule
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      # Retention policy
      dynamic "retention_policy" {
        for_each = share_properties.value.retention_policy != null ? [share_properties.value.retention_policy] : []
        content {
          days = retention_policy.value.days
        }
      }

      # SMB configuration
      dynamic "smb" {
        for_each = share_properties.value.smb != null ? [share_properties.value.smb] : []
        content {
          versions                        = smb.value.versions
          authentication_types            = smb.value.authentication_types
          kerberos_ticket_encryption_type = smb.value.kerberos_ticket_encryption_type
          channel_encryption_type         = smb.value.channel_encryption_type
          multichannel_enabled            = smb.value.multichannel_enabled
        }
      }
    }
  }

  # Network rules
  #checkov:skip=CKV_AZURE_36:False positive with dynamic blocks - https://github.com/bridgecrewio/checkov/issues/6724
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
    for_each = var.identity != null ? [1] : []
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

  # Immutability Policy
  dynamic "immutability_policy" {
    for_each = var.immutability_policy != null ? [var.immutability_policy] : []
    content {
      allow_protected_append_writes = immutability_policy.value.allow_protected_append_writes
      state                         = immutability_policy.value.state
      period_since_creation_in_days = immutability_policy.value.period_since_creation_in_days
    }
  }

  # SAS Policy
  dynamic "sas_policy" {
    for_each = var.sas_policy != null ? [var.sas_policy] : []
    content {
      expiration_period = sas_policy.value.expiration_period
      expiration_action = sas_policy.value.expiration_action
    }
  }

  # Routing configuration
  dynamic "routing" {
    for_each = var.routing != null ? [var.routing] : []
    content {
      choice                      = routing.value.choice
      publish_internet_endpoints  = routing.value.publish_internet_endpoints
      publish_microsoft_endpoints = routing.value.publish_microsoft_endpoints
    }
  }

  # Custom domain configuration
  dynamic "custom_domain" {
    for_each = var.custom_domain != null ? [var.custom_domain] : []
    content {
      name          = custom_domain.value.name
      use_subdomain = custom_domain.value.use_subdomain
    }
  }

  # Azure Files Authentication
  dynamic "azure_files_authentication" {
    for_each = var.azure_files_authentication != null ? [var.azure_files_authentication] : []
    content {
      directory_type = azure_files_authentication.value.directory_type

      dynamic "active_directory" {
        for_each = azure_files_authentication.value.active_directory != null ? [azure_files_authentication.value.active_directory] : []
        content {
          domain_name         = active_directory.value.domain_name
          domain_guid         = active_directory.value.domain_guid
          domain_sid          = active_directory.value.domain_sid
          storage_sid         = active_directory.value.storage_sid
          forest_name         = active_directory.value.forest_name
          netbios_domain_name = active_directory.value.netbios_domain_name
        }
      }
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

  depends_on = [
    azurerm_storage_account.storage_account
  ]

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
  for_each = { for private_endpoint in var.private_endpoints : private_endpoint.name => private_endpoint }

  name                = "${var.name}-pe-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  depends_on = [
    azurerm_storage_account.storage_account
  ]

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

# Diagnostic settings for storage account level metrics
resource "azurerm_monitor_diagnostic_setting" "monitor_diagnostic_setting" {
  count = var.diagnostic_settings.enabled ? 1 : 0

  name                           = "${var.name}-diag"
  target_resource_id             = azurerm_storage_account.storage_account.id
  log_analytics_workspace_id     = var.diagnostic_settings.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_settings.storage_account_id
  eventhub_authorization_rule_id = var.diagnostic_settings.eventhub_auth_rule_id

  depends_on = [
    azurerm_storage_account.storage_account
  ]

  # Storage account level only has metrics, no logs
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

  depends_on = [
    azurerm_storage_account.storage_account
  ]

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
  for_each = { for container in var.containers : container.name => container }

  name                  = each.value.name
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = each.value.container_access_type
  metadata              = each.value.metadata

  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

# Storage Queues
resource "azurerm_storage_queue" "storage_queue" {
  for_each = { for queue in var.queues : queue.name => queue }

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.storage_account.name
  metadata             = each.value.metadata

  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

# Storage Tables
resource "azurerm_storage_table" "storage_table" {
  for_each = { for table in var.tables : table.name => table }

  name                 = each.value.name
  storage_account_name = azurerm_storage_account.storage_account.name

  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

# File Shares
resource "azurerm_storage_share" "storage_share" {
  for_each = { for file_share in var.file_shares : file_share.name => file_share }

  name               = each.value.name
  storage_account_id = azurerm_storage_account.storage_account.id
  quota              = each.value.quota
  access_tier        = each.value.access_tier
  enabled_protocol   = each.value.enabled_protocol
  metadata           = each.value.metadata

  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

# Queue Properties (separate resource as queue_properties block is deprecated)
resource "azurerm_storage_account_queue_properties" "queue_properties" {
  count = var.queue_properties.logging != null ? 1 : 0

  storage_account_id = azurerm_storage_account.storage_account.id

  dynamic "logging" {
    for_each = var.queue_properties.logging != null ? [var.queue_properties.logging] : []
    content {
      delete                = logging.value.delete
      read                  = logging.value.read
      write                 = logging.value.write
      version               = logging.value.version
      retention_policy_days = logging.value.retention_policy_days
    }
  }

  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

# Static Website (separate resource as static_website block is deprecated)
resource "azurerm_storage_account_static_website" "static_website" {
  count = try(var.static_website.enabled, false) && try(var.static_website.index_document, null) != null ? 1 : 0

  storage_account_id = azurerm_storage_account.storage_account.id
  index_document     = try(var.static_website.index_document, null)
  error_404_document = try(var.static_website.error_404_document, null)

  depends_on = [
    azurerm_storage_account.storage_account
  ]
}
