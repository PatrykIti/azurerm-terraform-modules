provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_role_definition" "secrets_officer" {
  name  = "Key Vault Secrets Officer"
  scope = azurerm_resource_group.example.id
}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-rbac"
  location = var.location
}

module "key_vault" {
  source = "../../"

  name                = "kvrbacexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  rbac_authorization_enabled    = true
  public_network_access_enabled = true

  tags = {
    Environment = "Development"
    Example     = "RBAC"
  }
}

resource "azurerm_role_assignment" "secrets_officer" {
  scope              = module.key_vault.id
  role_definition_id = data.azurerm_role_definition.secrets_officer.id
  principal_id       = data.azurerm_client_config.current.object_id
}
