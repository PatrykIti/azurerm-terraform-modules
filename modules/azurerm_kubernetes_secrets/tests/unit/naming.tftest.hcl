# Naming validation tests for Kubernetes Secrets module

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

run "invalid_name_uppercase" {
  command = plan

  variables {
    name = "InvalidName"
  }

  expect_failures = [
    var.name,
  ]
}

run "invalid_name_special_chars" {
  command = plan

  variables {
    name = "invalid_name"
  }

  expect_failures = [
    var.name,
  ]
}

run "invalid_namespace" {
  command = plan

  variables {
    namespace = "InvalidNamespace"
  }

  expect_failures = [
    var.namespace,
  ]
}
