# Default behavior tests for Kubernetes Namespace module

mock_provider "kubernetes" {
  mock_resource "kubernetes_namespace_v1" {}
}

variables {
  name = "app"
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = var.wait_for_default_service_account == false
    error_message = "wait_for_default_service_account should default to false."
  }

  assert {
    condition     = length(var.labels) == 0
    error_message = "labels should be empty by default."
  }

  assert {
    condition     = length(var.annotations) == 0
    error_message = "annotations should be empty by default."
  }
}
