# Naming validation tests for Kubernetes Secrets module

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
