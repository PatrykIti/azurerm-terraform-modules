# Naming validation tests for Kubernetes Role module

mock_provider "kubernetes" {
  mock_resource "kubernetes_role_v1" {}
}

variables {
  name      = "intent-resolver-read"
  namespace = "intent-resolver"
  rules = [
    {
      api_groups = [""]
      resources  = ["pods"]
      verbs      = ["get"]
    }
  ]
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

run "invalid_namespace" {
  command = plan

  variables {
    namespace = "InvalidNamespace"
  }

  expect_failures = [
    var.namespace,
  ]
}
