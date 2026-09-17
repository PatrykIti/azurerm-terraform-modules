# Kubernetes Cluster Role Binding Module

resource "kubernetes_cluster_role_binding_v1" "cluster_role_binding" {
  metadata {
    name        = var.name
    labels      = var.labels
    annotations = var.annotations
  }

  role_ref {
    api_group = var.role_ref.api_group
    kind      = var.role_ref.kind
    name      = var.role_ref.name
  }

  dynamic "subject" {
    for_each = var.subjects
    content {
      kind      = subject.value.kind
      name      = subject.value.name
      namespace = subject.value.kind == "ServiceAccount" ? subject.value.namespace : null
      api_group = subject.value.kind == "ServiceAccount" ? "" : coalesce(try(subject.value.api_group, null), "rbac.authorization.k8s.io")
    }
  }
}
