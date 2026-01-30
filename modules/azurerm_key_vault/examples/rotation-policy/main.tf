provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-rotation"
  location = var.location
}

module "key_vault" {
  source = "../../"

  name                = "kvrotationex001"
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
        "Rotate",
        "GetRotationPolicy",
        "SetRotationPolicy"
      ]
    }
  ]

  keys = [
    {
      name     = "rotating-key"
      key_type = "RSA"
      key_size = 2048
      key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
      rotation_policy = {
        expire_after         = "P90D"
        notify_before_expiry = "P30D"
        automatic = {
          time_after_creation = "P30D"
        }
      }
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "RotationPolicy"
  }
}
