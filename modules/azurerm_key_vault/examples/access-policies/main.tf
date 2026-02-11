provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-access-policies"
  location = var.location
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "uai-kv-access-policies"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

module "key_vault" {
  source = "../../"

  name                = "kvaccesspol001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  rbac_authorization_enabled    = false
  public_network_access_enabled = true

  access_policies = [
    {
      name                    = "current-user"
      object_id               = data.azurerm_client_config.current.object_id
      tenant_id               = data.azurerm_client_config.current.tenant_id
      key_permissions         = ["Get", "List", "Create", "Delete", "Encrypt", "Decrypt"]
      secret_permissions      = ["Get", "List", "Set", "Delete"]
      certificate_permissions = ["Get", "List", "Create", "Delete", "Update"]
    },
    {
      name               = "app-identity"
      object_id          = azurerm_user_assigned_identity.example.principal_id
      tenant_id          = data.azurerm_client_config.current.tenant_id
      secret_permissions = ["Get", "List"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "AccessPolicies"
  }
}
