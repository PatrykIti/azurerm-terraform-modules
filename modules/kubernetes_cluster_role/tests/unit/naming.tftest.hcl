# Naming tests for Kubernetes Cluster Role

mock_provider "kubernetes" {
  mock_resource "kubernetes_cluster_role_v1" {}
}

variables {
  name = "namespace-reader"
  rules = [
    {
      resources = ["namespaces"]
      verbs     = ["get"]
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
