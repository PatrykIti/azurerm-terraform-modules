# Validation tests for Kubernetes Role module

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

run "missing_rules" {
  command = plan

  variables {
    rules = []
  }

  expect_failures = [
    var.rules,
  ]
}
