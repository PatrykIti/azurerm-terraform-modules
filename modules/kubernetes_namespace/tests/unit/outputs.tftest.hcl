# Output tests for Kubernetes Namespace module

mock_provider "kubernetes" {
  mock_resource "kubernetes_namespace_v1" {
    defaults = {
      id = "intent-resolver"
      metadata = {
        name             = "intent-resolver"
        generation       = 1
        resource_version = "123"
        uid              = "uid-123"
      }
    }
  }
}

variables {
  name = "intent-resolver"
  labels = {
    Environment = "Test"
  }
  annotations = {
    "owner.team" = "platform"
  }
}

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.id == "intent-resolver"
    error_message = "id output should match the namespace ID."
  }

  assert {
    condition     = output.name == "intent-resolver"
    error_message = "name output should match the namespace name."
  }

  assert {
    condition     = output.labels.Environment == "Test"
    error_message = "labels output should include the Environment label."
  }

  assert {
    condition     = output.annotations["owner.team"] == "platform"
    error_message = "annotations output should include owner.team."
  }
}
