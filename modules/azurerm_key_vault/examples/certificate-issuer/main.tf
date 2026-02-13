provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-cert-issuer"
  location = var.location
}

module "key_vault" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_key_vault?ref=KVv1.0.0"

  name                = "kvcertissuer01"
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
      certificate_permissions = [
        "GetIssuers",
        "ListIssuers",
        "SetIssuers",
        "DeleteIssuers",
        "ManageIssuers"
      ]
    }
  ]

  certificate_issuers = [
    {
      name          = "self"
      provider_name = "Self"
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "CertificateIssuer"
  }
}
