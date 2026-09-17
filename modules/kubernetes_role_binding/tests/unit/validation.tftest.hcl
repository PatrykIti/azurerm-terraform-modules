# Validation tests for Kubernetes RoleBinding module

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

run "missing_subjects" {
  command = plan

  variables {
    subjects = []
  }

  expect_failures = [var.subjects]
}

run "service_account_requires_namespace" {
  command = plan

  variables {
    subjects = [
      {
        kind = "ServiceAccount"
        name = "intent-resolver"
      }
    ]
  }

  expect_failures = [var.subjects]
}
