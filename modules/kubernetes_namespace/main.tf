# Kubernetes Namespace Module

resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name        = var.name
    labels      = var.labels
    annotations = var.annotations
  }

  wait_for_default_service_account = var.wait_for_default_service_account

  dynamic "timeouts" {
    for_each = var.timeouts.delete != null ? [var.timeouts] : []
    content {
      delete = try(timeouts.value.delete, null)
    }
  }
}
