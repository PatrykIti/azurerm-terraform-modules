# Secure Event Hub Namespace Example

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
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-ehns-secure"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-ehns-pe"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.10.1.0/24"]

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_user_assigned_identity" "cmk" {
  name                = "id-ehns-secure"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "GetRotationPolicy",
      "SetRotationPolicy",
      "Update"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.cmk.principal_id

    key_permissions = [
      "Get",
      "UnwrapKey",
      "WrapKey"
    ]
  }
}

resource "azurerm_key_vault_key" "example" {
  name         = "ehns-cmk"
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
}

module "eventhub_namespace" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_eventhub_namespace?ref=EHNSv1.0.0"

  name                = var.namespace_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku                           = "Standard"
  public_network_access_enabled = false
  local_authentication_enabled  = false
  minimum_tls_version           = "1.2"

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cmk.id]
  }

  customer_managed_key = {
    key_vault_key_ids         = [azurerm_key_vault_key.example.id]
    user_assigned_identity_id = azurerm_user_assigned_identity.cmk.id
  }

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}

resource "azurerm_private_endpoint" "eventhub_namespace" {
  name                = "pe-ehns-secure"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "psc-ehns-secure"
    private_connection_resource_id = module.eventhub_namespace.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }
}
