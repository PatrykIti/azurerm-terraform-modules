terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}

# Create a resource group for the example
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# ==============================================================================
# Prerequisites: Key Vault for Customer-Managed Key Encryption
# ==============================================================================

resource "azurerm_key_vault" "example" {
  name                = "kv-identity-access-ex"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  rbac_authorization_enabled      = true
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false # Set to true in production
}

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
    "wrapKey",
  ]

  depends_on = [
    azurerm_role_assignment.current_user_kv_admin
  ]
}

# Grant current user access to Key Vault
resource "azurerm_role_assignment" "current_user_kv_admin" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# ==============================================================================
# User-Assigned Identity
# ==============================================================================

resource "azurerm_user_assigned_identity" "storage" {
  name                = "uai-storage-identity-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

# Grant user-assigned identity access to Key Vault
resource "azurerm_role_assignment" "uai_kv_crypto_user" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}

# ==============================================================================
# Example 1: System-Assigned Identity Only
# ==============================================================================

module "storage_system_assigned" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name                     = "stsysidentityexample"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # System-assigned identity only
  identity = {
    type = "SystemAssigned"
  }

  # Enable OAuth authentication as default and disable shared keys
  default_to_oauth_authentication = true

  security_settings = {
    https_traffic_only_enabled        = true
    min_tls_version                   = "TLS1_2"
    shared_access_key_enabled         = false # Keyless authentication
    allow_nested_items_to_be_public   = false
    infrastructure_encryption_enabled = true
  }

  network_rules = {
    bypass   = ["AzureServices"]
    ip_rules = []
  }

  containers = [
    {
      name                  = "system-test"
      container_access_type = "private"
    }
  ]

  tags = {
    example       = "system-assigned-identity"
    identity_type = "SystemAssigned"
  }
}

# Grant system-assigned identity access to Key Vault (for potential future CMK use)
resource "azurerm_role_assignment" "system_identity_kv_access" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.storage_system_assigned.identity.principal_id
}

# ==============================================================================
# Example 2: User-Assigned Identity Only with CMK
# ==============================================================================

module "storage_user_assigned" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name                     = "stuseridentityexample"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # User-assigned identity only
  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }

  # Customer-managed key encryption using user-assigned identity
  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = true
    key_vault_key_id                  = azurerm_key_vault_key.storage.id
    user_assigned_identity_id         = azurerm_user_assigned_identity.storage.id
  }

  default_to_oauth_authentication = true

  security_settings = {
    https_traffic_only_enabled        = true
    min_tls_version                   = "TLS1_2"
    shared_access_key_enabled         = false
    allow_nested_items_to_be_public   = false
    infrastructure_encryption_enabled = true
  }

  network_rules = {
    bypass   = ["AzureServices"]
    ip_rules = []
  }

  containers = [
    {
      name                  = "user-test"
      container_access_type = "private"
    }
  ]

  tags = {
    example       = "user-assigned-identity"
    identity_type = "UserAssigned"
  }

  depends_on = [
    azurerm_role_assignment.uai_kv_crypto_user
  ]
}

# ==============================================================================
# Example 3: Both System and User-Assigned Identities with CMK
# ==============================================================================

module "storage_combined" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name                     = "stcombidentityexample"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Both system and user-assigned identities
  identity = {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }

  # Customer-managed key encryption using user-assigned identity
  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = true
    key_vault_key_id                  = azurerm_key_vault_key.storage.id
    user_assigned_identity_id         = azurerm_user_assigned_identity.storage.id
  }

  default_to_oauth_authentication = true

  security_settings = {
    https_traffic_only_enabled        = true
    min_tls_version                   = "TLS1_2"
    shared_access_key_enabled         = false
    allow_nested_items_to_be_public   = false
    infrastructure_encryption_enabled = true
  }

  network_rules = {
    bypass   = ["AzureServices"]
    ip_rules = []
  }

  containers = [
    {
      name                  = "combined-test"
      container_access_type = "private"
    },
    {
      name                  = "data"
      container_access_type = "private"
    }
  ]

  tags = {
    example       = "combined-identities"
    identity_type = "SystemAssigned+UserAssigned"
  }

  depends_on = [
    azurerm_role_assignment.uai_kv_crypto_user
  ]
}

# Grant combined account's system-assigned identity additional permissions
resource "azurerm_role_assignment" "combined_system_identity_kv_secrets" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.storage_combined.identity.principal_id
}

# ==============================================================================
# RBAC Assignments for Testing
# ==============================================================================

# Grant current user access to all storage accounts
resource "azurerm_role_assignment" "current_user_system" {
  scope                = module.storage_system_assigned.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "current_user_user" {
  scope                = module.storage_user_assigned.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "current_user_combined" {
  scope                = module.storage_combined.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Example: Container-level RBAC assignment
resource "azurerm_role_assignment" "container_level_access" {
  scope                = "${module.storage_combined.id}/blobServices/default/containers/data"
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}

# ==============================================================================
# Example Usage Patterns
# ==============================================================================

# Example of granting a specific Azure AD group access to a storage account
# Uncomment and update the object_id to use
# resource "azurerm_role_assignment" "group_access" {
#   scope                = module.storage_combined.id
#   role_definition_name = "Storage Blob Data Reader"
#   principal_id         = "YOUR-AZURE-AD-GROUP-OBJECT-ID"
# }

# Example of service principal access for applications
# resource "azurerm_role_assignment" "app_access" {
#   scope                = module.storage_user_assigned.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = "YOUR-APP-SERVICE-PRINCIPAL-OBJECT-ID"
# }
