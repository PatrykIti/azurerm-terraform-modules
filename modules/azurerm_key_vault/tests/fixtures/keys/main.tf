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
  name     = "rg-kv-keys-${var.random_suffix}"
  location = var.location
}

module "key_vault" {
  source = "../../../"

  name                = "kvkeys${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  rbac_authorization_enabled    = false
  public_network_access_enabled = true

  access_policies = [
    {
      name            = "current-user"
      object_id       = data.azurerm_client_config.current.object_id
      tenant_id       = data.azurerm_client_config.current.tenant_id
      key_permissions = ["Create", "Get", "List", "Delete", "Encrypt", "Decrypt", "WrapKey", "UnwrapKey", "Sign", "Verify"]
    }
  ]

  keys = [
    {
      name     = "rsa-key"
      key_type = "RSA"
      key_size = 2048
      key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
    }
  ]

  tags = {
    Environment = "Test"
    TestType    = "Keys"
  }
}
