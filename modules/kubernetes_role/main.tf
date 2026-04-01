# Kubernetes Role Module

resource "kubernetes_role_v1" "role" {
  metadata {
    name        = var.name
    namespace   = var.namespace
    labels      = var.labels
    annotations = var.annotations
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      api_groups     = rule.value.api_groups
      resources      = rule.value.resources
      verbs          = rule.value.verbs
      resource_names = try(rule.value.resource_names, null)
    }
  }
}
