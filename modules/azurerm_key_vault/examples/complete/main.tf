provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-complete-example"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-kv-complete-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "key_vault" {
  source = "../../"

  name                = "kvcompleteexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  rbac_authorization_enabled    = false
  public_network_access_enabled = true

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["0.0.0.0/0"]
  }

  access_policies = [
    {
      name      = "current-user"
      object_id = data.azurerm_client_config.current.object_id
      tenant_id = data.azurerm_client_config.current.tenant_id
      certificate_permissions = [
        "Create",
        "Delete",
        "Get",
        "Import",
        "List",
        "Purge",
        "Recover",
        "Update"
      ]
      key_permissions = [
        "Create",
        "Decrypt",
        "Delete",
        "Encrypt",
        "Get",
        "List",
        "Sign",
        "UnwrapKey",
        "Verify",
        "WrapKey",
        "Rotate",
        "GetRotationPolicy",
        "SetRotationPolicy"
      ]
      secret_permissions  = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
      storage_permissions = ["Get", "List", "Set", "Delete", "GetSAS", "SetSAS", "RegenerateKey"]
    }
  ]

  keys = [
    {
      name     = "app-key"
      key_type = "RSA"
      key_size = 2048
      key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
    }
  ]

  secrets = [
    {
      name  = "app-secret"
      value = "example-secret"
    }
  ]

  certificates = [
    {
      name = "app-cert"
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
          extended_key_usage = ["1.3.6.1.5.5.7.3.1"]
          subject_alternative_names = {
            dns_names = ["example.com", "www.example.com"]
          }
        }
        lifetime_actions = [
          {
            action_type        = "EmailContacts"
            days_before_expiry = 30
          }
        ]
      }
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
    Example     = "Complete"
  }
}
