provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "ai" {
  name                = var.user_assigned_identity_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_key_vault" "example" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled = false
  purge_protection_enabled   = true
  soft_delete_retention_days = 90
}

resource "azurerm_key_vault_access_policy" "current" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create", "Delete", "Get", "GetRotationPolicy", "List", "Purge", "Recover", "Update"
  ]
}

resource "azurerm_key_vault_access_policy" "ai" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.ai.principal_id

  key_permissions = [
    "Get", "GetRotationPolicy", "UnwrapKey", "WrapKey"
  ]
}

resource "azurerm_key_vault_key" "ai" {
  name         = var.key_vault_key_name
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
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.30.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

module "ai_services_account" {
  source = "../../"

  name                  = var.ai_services_account_name
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  sku_name              = var.sku_name
  custom_subdomain_name = var.ai_services_account_name

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
    name                       = var.diagnostic_setting_name
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
    areas                      = ["all"]
  }]

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }

  depends_on = [azurerm_key_vault_access_policy.ai]
}

resource "azurerm_private_endpoint" "ai_services" {
  name                = var.private_endpoint_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${var.private_endpoint_name}-psc"
    private_connection_resource_id = module.ai_services_account.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }
}
