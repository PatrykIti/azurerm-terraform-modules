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
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "example" {
  name                = var.user_assigned_identity_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_key_vault" "example" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "GetRotationPolicy"
    ]
    secret_permissions = ["Get"]
  }

  access_policy {
    tenant_id = azurerm_user_assigned_identity.example.tenant_id
    object_id = azurerm_user_assigned_identity.example.principal_id

    key_permissions = [
      "Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"
    ]
    secret_permissions = ["Get"]
  }
}

resource "azurerm_key_vault_key" "example" {
  name         = var.key_vault_key_name
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}

module "cognitive_account" {
  source = "../.."

  name                = var.account_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "OpenAI"
  sku_name = "S0"

  public_network_access_enabled = true
  local_auth_enabled            = true

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  customer_managed_key = {
    key_vault_key_id      = azurerm_key_vault_key.example.id
    identity_client_id    = azurerm_user_assigned_identity.example.client_id
    use_separate_resource = true
  }

  tags = var.tags
}
