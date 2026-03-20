# Validation tests for Kubernetes Cluster Role

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

run "missing_rules_and_aggregation" {
  command = plan

  variables {
    rules            = []
    aggregation_rule = null
  }

  expect_failures = [
    var.rules,
  ]
}
