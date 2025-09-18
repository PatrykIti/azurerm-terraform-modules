# Secure Storage Account with Private Endpoints Example
# This example demonstrates a highly secure storage account configuration
# suitable for production environments with sensitive data

terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.43.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Data source for current client
data "azurerm_client_config" "current" {}


# Resource Group with resource lock for production
resource "azurerm_resource_group" "example" {
  name     = "rg-${var.resource_prefix}-storage-example"
  location = var.location

  tags = merge(var.tags, {
    Example = "secure-private-endpoint"
  })
}

# Resource lock to prevent accidental deletion
resource "azurerm_management_lock" "resource_group" {
  name       = "rg-lock"
  scope      = azurerm_resource_group.example.id
  lock_level = "CanNotDelete"
  notes      = "This resource group contains critical security infrastructure"
}

# Virtual Network for Private Endpoints
resource "azurerm_virtual_network" "example" {
  name                = "vnet-storage-secure"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet for Private Endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies = var.enable_private_endpoint_policies ? "Enabled" : "Disabled"
}

# Subnet for Application
resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone" "table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

# Private DNS Zone for DFS (Data Lake Gen2)
resource "azurerm_private_dns_zone" "dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

# Private DNS Zone for Web (Static Website)
resource "azurerm_private_dns_zone" "web" {
  name                = "privatelink.web.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

# Link DNS zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "blob-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  name                  = "file-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "queue" {
  name                  = "queue-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.queue.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "table" {
  name                  = "table-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.table.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "dfs" {
  name                  = "dfs-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.dfs.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "web" {
  name                  = "web-vnet-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.web.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false
}

# Key Vault for Customer Managed Keys
resource "azurerm_key_vault" "example" {
  name                = "kv-storage-secprivateep"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = false
  enabled_for_template_deployment = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_ranges
  }

  tags = var.tags
}

# User Assigned Identity for Storage Account
resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-storage-${var.resource_prefix}-secpe"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = var.tags
}

# Key Vault Access Policy for Storage Identity
resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.storage.principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey"
  ]
}

# Key Vault Access Policy for Current User (for key creation)
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "List",
    "Update",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]
}

# Customer Managed Key
resource "azurerm_key_vault_key" "storage" {
  name         = "storage-encryption-key"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P${var.key_rotation_reminder_days}D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P${var.key_rotation_reminder_days}D"
  }

  depends_on = [
    azurerm_key_vault_access_policy.storage,
    azurerm_key_vault_access_policy.current_user
  ]
}

# Log Analytics Workspace for Diagnostics
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-storage-secure-privep"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
}


# Secure Storage Account Module
module "secure_storage" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.2.0"

  name                = "stsecureprivateendpoint"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Configurable performance and replication
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = "StorageV2"

  # Maximum security settings
  security_settings = {
    https_traffic_only_enabled        = true
    min_tls_version                   = "TLS1_2"
    shared_access_key_enabled         = true # Required for Terraform to manage the resource
    infrastructure_encryption_enabled = var.enable_infrastructure_encryption
    allow_nested_items_to_be_public   = false
  }

  # Note: public_network_access_enabled = false would be set here if the module supported it

  # Encryption settings
  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = var.enable_infrastructure_encryption
    key_vault_key_id                  = azurerm_key_vault_key.storage.id
    user_assigned_identity_id         = azurerm_user_assigned_identity.storage.id
  }

  # Network security - deny all by default
  network_rules = {
    bypass                     = ["AzureServices"]
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = [azurerm_subnet.app.id]
  }


  # Identity for managed authentication
  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }


  # Enhanced data protection
  blob_properties = {
    versioning_enabled  = true
    change_feed_enabled = true
    delete_retention_policy = {
      enabled = true
      days    = 30
    }
    container_delete_retention_policy = {
      enabled = true
      days    = 30
    }
  }


  # Containers with security configurations
  containers = [
    {
      name                  = "secure-data"
      container_access_type = "private"
    },
    {
      name                  = "audit-logs"
      container_access_type = "private"
    }
  ]

  # File shares with security configurations
  file_shares = [
    {
      name             = "secure-share"
      quota            = 100
      access_tier      = "Hot"
      enabled_protocol = "SMB"
    }
  ]

  tags = merge(var.tags, {
    Purpose = "Secure data storage with private endpoints"
  })

  depends_on = [
    azurerm_key_vault_access_policy.storage,
    azurerm_private_dns_zone_virtual_network_link.blob,
    azurerm_private_dns_zone_virtual_network_link.file
  ]
}

# Private endpoints for all storage services
resource "azurerm_private_endpoint" "blob" {
  name                = "${module.secure_storage.name}-pe-blob"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${module.secure_storage.name}-psc-blob"
    private_connection_resource_id = module.secure_storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  tags = merge(var.tags, {
    Purpose = "Blob storage private access"
  })
}

resource "azurerm_private_endpoint" "file" {
  name                = "${module.secure_storage.name}-pe-file"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${module.secure_storage.name}-psc-file"
    private_connection_resource_id = module.secure_storage.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.file.id]
  }

  tags = merge(var.tags, {
    Purpose = "File storage private access"
  })
}

resource "azurerm_private_endpoint" "queue" {
  name                = "${module.secure_storage.name}-pe-queue"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${module.secure_storage.name}-psc-queue"
    private_connection_resource_id = module.secure_storage.id
    is_manual_connection           = false
    subresource_names              = ["queue"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.queue.id]
  }

  tags = merge(var.tags, {
    Purpose = "Queue storage private access"
  })
}

resource "azurerm_private_endpoint" "table" {
  name                = "${module.secure_storage.name}-pe-table"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${module.secure_storage.name}-psc-table"
    private_connection_resource_id = module.secure_storage.id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.table.id]
  }

  tags = merge(var.tags, {
    Purpose = "Table storage private access"
  })
}

# Diagnostic settings for comprehensive logging
resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  name                       = "${module.secure_storage.name}-diag"
  target_resource_id         = module.secure_storage.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  # Storage account level only has metrics, no logs
  metric {
    category = "Transaction"
  }

  metric {
    category = "Capacity"
  }
}

resource "azurerm_monitor_diagnostic_setting" "blob_service" {
  name                       = "${module.secure_storage.name}-blob-diag"
  target_resource_id         = "${module.secure_storage.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
  }

  metric {
    category = "Capacity"
  }
}