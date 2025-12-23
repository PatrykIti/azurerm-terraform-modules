# Default behavior tests for Kubernetes Secrets module

mock_provider "azurerm" {
  mock_data "azurerm_key_vault_secret" {
    defaults = {
      value = "mock-secret"
    }
  }
}

mock_provider "kubernetes" {
  mock_resource "kubernetes_secret_v1" {}
  mock_resource "kubernetes_manifest" {}
}

variables {
  strategy  = "manual"
  namespace = "app"
  name      = "app-secrets"
  manual = {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
    secrets = [
      {
        name                  = "db-password"
        key_vault_secret_name = "db-password"
        kubernetes_secret_key = "DB_PASSWORD"
      }
    ]
  }
}

run "manual_defaults_plan" {
  command = plan
}

run "csi_defaults_plan" {
  command = plan

  variables {
    strategy = "csi"
    manual   = null
    csi = {
      tenant_id      = "00000000-0000-0000-0000-000000000000"
      key_vault_name = "test-kv"
      objects = [
        {
          name        = "db-password"
          object_name = "db-password"
          object_type = "secret"
        }
      ]
    }
  }
}

run "eso_defaults_plan" {
  command = plan

  variables {
    strategy = "eso"
    manual   = null
    eso = {
      secret_store = {
        kind           = "SecretStore"
        name           = "kv-store"
        tenant_id      = "00000000-0000-0000-0000-000000000000"
        key_vault_name = "test-kv"
        auth = {
          type = "managed_identity"
          managed_identity = {
            client_id = "00000000-0000-0000-0000-000000000000"
          }
        }
      }
      external_secrets = [
        {
          name = "db-secret"
          remote_ref = {
            name = "db-password"
          }
          target = {
            secret_name = "app-secrets"
            secret_key  = "DB_PASSWORD"
          }
        }
      ]
    }
  }
}
