terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-cog-secure-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-cog-secure-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.50.0.0/16"]
}

resource "azurerm_subnet" "private_endpoint" {
  name                 = "snet-pe-cog-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.50.1.0/24"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "uai-cog-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_key_vault" "example" {
  name                       = "kvcog${var.random_suffix}"
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
  name         = "cog-secure-key-${var.random_suffix}"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}

module "cognitive_account" {
  source = "../../.."

  name                = "cogopenai${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "OpenAI"
  sku_name = "S0"

  public_network_access_enabled = false
  local_auth_enabled            = false
  custom_subdomain_name         = "cogopenai${var.random_suffix}"

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

resource "time_sleep" "wait_for_cognitive_account" {
  # Wait for the cognitive account provisioning to fully settle before creating PE.
  create_duration = "120s"
  depends_on      = [module.cognitive_account]
}

resource "azurerm_private_dns_zone" "openai" {
  name                = var.private_dns_zone_name
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai" {
  name                  = "pdns-cog-${var.random_suffix}"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.openai.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_endpoint" "openai" {
  name                = "pe-cog-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoint.id
  depends_on          = [time_sleep.wait_for_cognitive_account]

  private_service_connection {
    name                           = "pe-cog-${var.random_suffix}-psc"
    private_connection_resource_id = module.cognitive_account.id
    subresource_names              = [var.private_endpoint_subresource]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pe-cog-${var.random_suffix}-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.openai.id]
  }
}
