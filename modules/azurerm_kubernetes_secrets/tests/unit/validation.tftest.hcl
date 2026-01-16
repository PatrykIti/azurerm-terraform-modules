# Validation tests for Kubernetes Secrets module

mock_provider "kubernetes" {
  mock_resource "kubernetes_secret_v1" {}
  mock_resource "kubernetes_manifest" {}
}

variables {
  strategy  = "manual"
  namespace = "app"
  name      = "app-secrets"
  manual = {
    secrets = [
      {
        name                  = "db-password"
        kubernetes_secret_key = "DB_PASSWORD"
        value                 = "mock-secret"
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
