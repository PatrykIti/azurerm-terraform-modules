provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-basic-example"
  location = var.location
}

module "key_vault" {
  source = "../../"

  name                = "kvbasicexample001"
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
      secret_permissions = ["Get", "Set", "List", "Delete"]
    }
  ]

  secrets = [
    {
      name  = "app-secret"
      value = "example-secret"
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
