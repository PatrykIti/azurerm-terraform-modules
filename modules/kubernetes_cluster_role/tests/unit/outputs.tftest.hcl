# Output tests for Kubernetes Cluster Role

mock_provider "kubernetes" {
  mock_resource "kubernetes_cluster_role_v1" {
    defaults = {
      id = "namespace-reader"
      metadata = {
        name = "namespace-reader"
      }
    }
  }
}

variables {
  name = "namespace-reader"
  rules = [{
    resources = ["namespaces"]
    verbs     = ["get"]
  }]
}

run "verify_outputs" {
  command = apply
  assert {
    condition     = output.name == "namespace-reader"
    error_message = "name output should match ClusterRole name."
  }
}
