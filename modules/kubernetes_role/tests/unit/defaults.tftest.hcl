# Default behavior tests for Kubernetes Role module

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

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(var.labels) == 0
    error_message = "labels should be empty by default."
  }

  assert {
    condition     = length(var.annotations) == 0
    error_message = "annotations should be empty by default."
  }
}
