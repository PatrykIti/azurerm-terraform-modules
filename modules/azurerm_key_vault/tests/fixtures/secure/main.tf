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

data "azurerm_role_definition" "key_vault_admin" {
  name  = "Key Vault Administrator"
  scope = azurerm_resource_group.example.id
}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-secure-${var.random_suffix}"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-kv-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-kv-${var.random_suffix}"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.30.1.0/24"]

  private_endpoint_network_policies_enabled = false
}

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "kv-dns-${var.random_suffix}"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

module "key_vault" {
  source = "../../../"

  name                = "kvsec${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  rbac_authorization_enabled    = true
  public_network_access_enabled = false
  purge_protection_enabled      = true

  network_acls = {
    bypass         = "None"
    default_action = "Deny"
  }

  tags = {
    Environment = "Test"
    TestType    = "Secure"
  }
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-kv-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "pe-kv-${var.random_suffix}-psc"
    private_connection_resource_id = module.key_vault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "kv-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
  }
}

resource "azurerm_role_assignment" "key_vault_admin" {
  scope              = module.key_vault.id
  role_definition_id = data.azurerm_role_definition.key_vault_admin.id
  principal_id       = data.azurerm_client_config.current.object_id
}
