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

resource "azurerm_log_analytics_cluster" "example" {
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.example.name
  location            = var.cluster_location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault" "example" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "GetRotationPolicy",
      "List",
    ]

    secret_permissions = [
      "Set",
    ]
  }
}

resource "azurerm_key_vault_access_policy" "cluster" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = azurerm_log_analytics_cluster.example.identity[0].tenant_id
  object_id    = azurerm_log_analytics_cluster.example.identity[0].principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}

resource "azurerm_key_vault_key" "example" {
  name         = "law-cmk"
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
}

module "log_analytics_workspace" {
  source = "../../"

  name                = var.workspace_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  cluster_customer_managed_keys = [
    {
      name                     = "cmk"
      log_analytics_cluster_id = azurerm_log_analytics_cluster.example.id
      key_vault_key_id         = azurerm_key_vault_key.example.id
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Cluster CMK"
  }
}
