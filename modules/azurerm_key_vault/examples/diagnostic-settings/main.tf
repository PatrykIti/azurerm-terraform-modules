provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-diagnostics"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-kv-diag-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "key_vault" {
  source = "../../"

  name                = "kvdiagexample001"
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

  diagnostic_settings = [
    {
      name                       = "diag"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      areas                      = ["all"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Diagnostics"
  }
}
