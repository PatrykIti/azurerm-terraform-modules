# Output tests for Kubernetes RoleBinding module

mock_provider "kubernetes" {
  mock_resource "kubernetes_role_binding_v1" {
    defaults = {
      id = "intent-resolver/intent-resolver-read-users"
      metadata = {
        name      = "intent-resolver-read-users"
        namespace = "intent-resolver"
      }
    }
  }
}

variables {
  name      = "intent-resolver-read-users"
  namespace = "intent-resolver"
  role_ref = {
    kind = "Role"
    name = "intent-resolver-read"
  }
  subjects = [
    {
      kind = "User"
      name = "00000000-0000-0000-0000-000000000000"
    }
  ]
}

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.name == "intent-resolver-read-users"
    error_message = "name output should match the RoleBinding name."
  }

  assert {
    condition     = output.namespace == "intent-resolver"
    error_message = "namespace output should match the RoleBinding namespace."
  }

  assert {
    condition     = output.role_ref.name == "intent-resolver-read"
    error_message = "role_ref output should match the referenced role."
  }

  assert {
    condition     = length(output.subjects) == 1
    error_message = "subjects output should contain one subject."
  }
}
