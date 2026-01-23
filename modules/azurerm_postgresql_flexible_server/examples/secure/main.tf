terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
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

resource "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.40.0.0/16"]
}

resource "azurerm_subnet" "postgresql" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.40.1.0/24"]

  delegation {
    name = "postgresql-flexible-server"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name                  = "pdzvnet-pgfs-secure-example"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_user_assigned_identity" "postgresql" {
  name                = var.user_assigned_identity_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_key_vault" "postgresql" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
}

resource "azurerm_role_assignment" "current_user_kv" {
  scope                = azurerm_key_vault.postgresql.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "postgresql_identity_kv" {
  scope                = azurerm_key_vault.postgresql.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.postgresql.principal_id
}

resource "azurerm_key_vault_key" "postgresql" {
  name         = "pgfs-key"
  key_vault_id = azurerm_key_vault.postgresql.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["encrypt", "decrypt", "wrapKey", "unwrapKey"]

  depends_on = [
    azurerm_role_assignment.current_user_kv
  ]
}

resource "random_password" "admin" {
  length      = 24
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  special     = false
}

module "postgresql_flexible_server" {
  source = "../../"

  name                = var.server_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name           = var.sku_name
  postgresql_version = var.postgresql_version

  administrator_login    = var.administrator_login
  administrator_password = random_password.admin.result

  authentication = {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  active_directory_administrator = {
    principal_name = var.aad_admin_principal_name
    object_id      = var.aad_admin_object_id
    principal_type = var.aad_admin_principal_type
  }

  network = {
    public_network_access_enabled = false
    delegated_subnet_id           = azurerm_subnet.postgresql.id
    private_dns_zone_id           = azurerm_private_dns_zone.postgresql.id
  }

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.postgresql.id]
  }

  customer_managed_key = {
    key_vault_key_id                  = azurerm_key_vault_key.postgresql.id
    primary_user_assigned_identity_id = azurerm_user_assigned_identity.postgresql.id
  }

  backup = {
    retention_days               = 30
    geo_redundant_backup_enabled = false
  }

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }

  depends_on = [
    azurerm_role_assignment.postgresql_identity_kv
  ]
}
