# Output tests for Kubernetes Secrets module

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

run "manual_outputs" {
  command = apply

  assert {
    condition     = output.strategy == "manual"
    error_message = "strategy output should be manual"
  }

  assert {
    condition     = output.kubernetes_secret_name == "app-secrets"
    error_message = "kubernetes_secret_name should match module name for manual strategy"
  }
}

run "csi_outputs" {
  command = apply

  variables {
    strategy = "csi"
    manual   = null
    name     = "app-spc"
    csi = {
      tenant_id                 = "00000000-0000-0000-0000-000000000000"
      key_vault_name            = "test-kv"
      sync_to_kubernetes_secret = true
      kubernetes_secret_name    = "app-secrets"
      objects = [
        {
          name        = "db-password"
          object_name = "db-password"
          object_type = "secret"
          secret_key  = "DB_PASSWORD"
        }
      ]
    }
  }

  assert {
    condition     = output.secret_provider_class_name == "app-spc"
    error_message = "secret_provider_class_name should match name for CSI"
  }

  assert {
    condition     = output.kubernetes_secret_name == "app-secrets"
    error_message = "kubernetes_secret_name should be set when CSI sync is enabled"
  }
}

run "eso_outputs" {
  command = apply

  variables {
    strategy = "eso"
    manual   = null
    name     = "app-eso"
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

  assert {
    condition     = output.secret_store_name == "kv-store"
    error_message = "secret_store_name should match ESO SecretStore name"
  }

  assert {
    condition     = length(output.external_secret_names) == 1
    error_message = "external_secret_names should include one secret"
  }
}
