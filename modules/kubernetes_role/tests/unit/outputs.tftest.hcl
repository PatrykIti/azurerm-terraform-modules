# Output tests for Kubernetes Role module

mock_provider "kubernetes" {
  mock_resource "kubernetes_role_v1" {
    defaults = {
      id = "intent-resolver/intent-resolver-read"
      metadata = {
        name      = "intent-resolver-read"
        namespace = "intent-resolver"
      }
    }
  }
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

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.id == "intent-resolver/intent-resolver-read"
    error_message = "id output should match the role ID."
  }

  assert {
    condition     = output.name == "intent-resolver-read"
    error_message = "name output should match the role name."
  }

  assert {
    condition     = output.namespace == "intent-resolver"
    error_message = "namespace output should match the role namespace."
  }

  assert {
    condition     = length(output.rules) == 1
    error_message = "rules output should contain one rule."
  }
}
