provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-certs"
  location = var.location
}

module "key_vault" {
  source = "../../"

  name                = "kvcertsexample01"
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
      certificate_permissions = ["Get", "List", "Create", "Delete", "Update", "Import"]
    }
  ]

  certificates = [
    {
      name = "tls-cert"
      certificate_policy = {
        issuer_parameters = {
          name = "Self"
        }
        key_properties = {
          exportable = true
          key_type   = "RSA"
          key_size   = 2048
          reuse_key  = true
        }
        secret_properties = {
          content_type = "application/x-pkcs12"
        }
        x509_certificate_properties = {
          subject            = "CN=example.com"
          validity_in_months = 12
          key_usage          = ["digitalSignature", "keyEncipherment"]
          subject_alternative_names = {
            dns_names = ["example.com"]
          }
        }
      }
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Certificates"
  }
}
