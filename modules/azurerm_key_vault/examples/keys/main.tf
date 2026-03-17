provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-keys"
  location = var.location
}

module "key_vault" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_key_vault?ref=KVv1.0.0"

  name                = "kvkeysexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  rbac_authorization_enabled    = false
  public_network_access_enabled = true

  access_policies = [
    {
      name      = "current-user"
      object_id = data.azurerm_client_config.current.object_id
      tenant_id = data.azurerm_client_config.current.tenant_id
      key_permissions = [
        "Create",
        "Get",
        "List",
        "Delete",
        "Encrypt",
        "Decrypt",
        "Sign",
        "Verify",
        "WrapKey",
        "UnwrapKey"
      ]
    }
  ]

  keys = [
    {
      name     = "rsa-key"
      key_type = "RSA"
      key_size = 2048
      key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
    },
    {
      name     = "ec-key"
      key_type = "EC"
      curve    = "P-256"
      key_opts = ["sign", "verify"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Keys"
  }
}
