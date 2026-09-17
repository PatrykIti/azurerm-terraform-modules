# Output tests for Kubernetes Cluster Role Binding

mock_provider "kubernetes" {
  mock_resource "kubernetes_cluster_role_binding_v1" {
    defaults = {
      id = "namespace-reader-user"
      metadata = {
        name = "namespace-reader-user"
      }
    }
  }
}

variables {
  name = "namespace-reader-user"
  role_ref = {
    name = "namespace-reader"
  }
  subjects = [{
    kind = "User"
    name = "00000000-0000-0000-0000-000000000000"
  }]
}

run "verify_outputs" {
  command = apply
  assert {
    condition     = output.name == "namespace-reader-user"
    error_message = "name output should match ClusterRoleBinding name."
  }
}
