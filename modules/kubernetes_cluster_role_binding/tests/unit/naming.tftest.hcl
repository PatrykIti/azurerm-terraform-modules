# Naming tests for Kubernetes Cluster Role Binding

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

run "invalid_name_uppercase" {
  command = plan

  variables {
    name = "InvalidName"
  }

  expect_failures = [
    var.name,
  ]
}
