# Default behavior tests for Kubernetes Secrets module

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
