# Validation tests for Kubernetes Cluster Role Binding

mock_provider "kubernetes" {
  mock_resource "kubernetes_cluster_role_binding_v1" {}
}

variables {
  name = "namespace-reader-user"
  role_ref = {
    name = "namespace-reader"
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

  expect_failures = [
    var.subjects,
  ]
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

  expect_failures = [
    var.subjects,
  ]
}
