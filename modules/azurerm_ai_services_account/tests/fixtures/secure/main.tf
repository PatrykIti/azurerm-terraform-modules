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
  name     = "rg-ai-services-secure-${var.random_suffix}"
  location = var.location
}

resource "azurerm_user_assigned_identity" "ai" {
  name                = "id-ai-services-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_key_vault" "example" {
  name                = "kvaisec${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enable_rbac_authorization  = false
  purge_protection_enabled   = true
  soft_delete_retention_days = 90
}

resource "azurerm_key_vault_access_policy" "current" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create", "Get", "Delete", "Purge", "Recover", "Update", "List"
  ]
}

resource "azurerm_key_vault_access_policy" "ai" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.ai.principal_id

  key_permissions = [
    "Get", "UnwrapKey", "WrapKey"
  ]
}

resource "azurerm_key_vault_key" "ai" {
  name         = "ai-services-key"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["wrapKey", "unwrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.current,
    azurerm_key_vault_access_policy.ai
  ]
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-ai-services-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-ai-services-${var.random_suffix}"
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-ai-services-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.30.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

module "ai_services_account" {
  source = "../../.."

  name                = "aiservices-secure-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "S0"

  public_network_access        = "Disabled"
  local_authentication_enabled = false

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ai.id]
  }

  customer_managed_key = {
    key_vault_key_id   = azurerm_key_vault_key.ai.id
    identity_client_id = azurerm_user_assigned_identity.ai.client_id
  }

  diagnostic_settings = [{
    name                       = "ai-services-secure-${var.random_suffix}"
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    areas                      = ["all"]
  }]

  tags = var.tags

  depends_on = [azurerm_key_vault_access_policy.ai]
}

resource "azurerm_private_endpoint" "ai_services" {
  name                = "pe-ai-services-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "pe-ai-services-${var.random_suffix}-psc"
    private_connection_resource_id = module.ai_services_account.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }
}
