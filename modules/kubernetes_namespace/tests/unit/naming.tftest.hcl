# Naming validation tests for Kubernetes Namespace module

mock_provider "kubernetes" {
  mock_resource "kubernetes_namespace_v1" {}
}

variables {
  name = "app"
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
