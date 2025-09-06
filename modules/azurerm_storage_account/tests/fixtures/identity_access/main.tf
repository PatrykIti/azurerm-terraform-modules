terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.41.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "rg-dpc-ida-${var.random_suffix}"
  location = var.location
}

# Key Vault for CMK
resource "azurerm_key_vault" "test" {
  name                       = "kvdpcida${var.random_suffix}"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

resource "azurerm_key_vault_key" "test" {
  name         = "test-key"
  key_vault_id = azurerm_key_vault.test.id
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
    azurerm_role_assignment.current_user_kv
  ]
}

# Grant current user access to Key Vault
resource "azurerm_role_assignment" "current_user_kv" {
  scope                = azurerm_key_vault.test.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# User-assigned identity
resource "azurerm_user_assigned_identity" "test" {
  name                = "uai-dpc-ida-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

# Grant UAI access to Key Vault
resource "azurerm_role_assignment" "uai_kv_access" {
  scope                = azurerm_key_vault.test.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

module "storage_account" {
  source = "../../.."

  name                     = "dpcida${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Both system and user-assigned identity
  identity = {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  # Enable CMK encryption
  encryption = {
    enabled                           = true
    infrastructure_encryption_enabled = true
    key_vault_key_id                  = azurerm_key_vault_key.test.id
    user_assigned_identity_id         = azurerm_user_assigned_identity.test.id
  }

  # Keyless authentication
  default_to_oauth_authentication = true

  security_settings = {
    https_traffic_only_enabled        = true
    min_tls_version                   = "TLS1_2"
    shared_access_key_enabled         = false
    allow_nested_items_to_be_public   = false
    infrastructure_encryption_enabled = true
  }

  containers = [
    {
      name                  = "test-container"
      container_access_type = "private"
    }
  ]

  tags = {
    Environment = "Test"
    TestType    = "IdentityAccess"
  }

  depends_on = [
    azurerm_role_assignment.uai_kv_access
  ]
}

# Grant system identity access to Key Vault
resource "azurerm_role_assignment" "system_identity_kv" {
  scope                = azurerm_key_vault.test.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.storage_account.identity.principal_id

  depends_on = [
    module.storage_account
  ]
}

output "storage_account_name" {
  value = module.storage_account.name
}

output "storage_account_id" {
  value = module.storage_account.id
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "system_identity_principal_id" {
  value = module.storage_account.identity.principal_id
}

output "key_vault_id" {
  value = azurerm_key_vault.test.id
}

output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.test.id
}