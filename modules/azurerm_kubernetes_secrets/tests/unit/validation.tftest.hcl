# Validation tests for Kubernetes Secrets module

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

run "strategy_mismatch" {
  command = plan

  variables {
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

  expect_failures = [
    var.strategy,
  ]
}

run "missing_strategy_block" {
  command = plan

  variables {
    strategy = "csi"
    csi      = null
  }

  expect_failures = [
    var.strategy,
  ]
}

run "csi_sync_requires_secret_key" {
  command = plan

  variables {
    strategy = "csi"
    manual   = null
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
        }
      ]
    }
  }

  expect_failures = [
    var.csi,
  ]
}

run "csi_invalid_object_type" {
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
          object_type = "invalid"
        }
      ]
    }
  }

  expect_failures = [
    var.csi,
  ]
}

run "eso_key_vault_xor" {
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
        key_vault_url  = "https://test-kv.vault.azure.net"
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

  expect_failures = [
    var.eso,
  ]
}
