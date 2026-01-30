terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-kv-complete-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "lawkv${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "key_vault" {
  source = "../../../"

  name                = "kvcomp${var.random_suffix}"
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
      name                    = "current-user"
      object_id               = data.azurerm_client_config.current.object_id
      tenant_id               = data.azurerm_client_config.current.tenant_id
      certificate_permissions = ["Create", "Delete", "Get", "Import", "List", "Purge", "Recover", "Update"]
      key_permissions         = ["Create", "Get", "List", "Delete", "Encrypt", "Decrypt", "WrapKey", "UnwrapKey", "Sign", "Verify", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
      secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
      storage_permissions     = ["Get", "List", "Set", "Delete", "GetSAS", "SetSAS", "RegenerateKey"]
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
          subject_alternative_names = {
            dns_names = ["example.com"]
          }
        }
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
    Environment = "Test"
    TestType    = "Complete"
  }
}
