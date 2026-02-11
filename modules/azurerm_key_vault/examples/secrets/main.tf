provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-secrets"
  location = var.location
}

module "key_vault" {
  source = "../../"

  name                = "kvsecretsexample1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  rbac_authorization_enabled    = false
  public_network_access_enabled = true

  access_policies = [
    {
      name               = "current-user"
      object_id          = data.azurerm_client_config.current.object_id
      tenant_id          = data.azurerm_client_config.current.tenant_id
      secret_permissions = ["Get", "List", "Set", "Delete"]
    }
  ]

  secrets = [
    {
      name  = "app-secret"
      value = "example-secret"
    },
    {
      name             = "write-only-secret"
      value_wo         = "example-write-only"
      value_wo_version = 1
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Secrets"
  }
}
