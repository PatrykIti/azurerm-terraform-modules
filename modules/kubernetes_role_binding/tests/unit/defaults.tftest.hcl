# Default behavior tests for Kubernetes RoleBinding module

mock_provider "kubernetes" {
  mock_resource "kubernetes_role_binding_v1" {}
}

variables {
  name      = "intent-resolver-read-users"
  namespace = "intent-resolver"
  role_ref = {
    name = "intent-resolver-read"
  }
  subjects = [
    {
      kind = "User"
      name = "00000000-0000-0000-0000-000000000000"
    }
  ]
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = var.role_ref.kind == "Role"
    error_message = "role_ref.kind should default to Role."
  }
}
