# Kubernetes Cluster Role Module

resource "kubernetes_cluster_role_v1" "cluster_role" {
  metadata {
    name        = var.name
    labels      = var.labels
    annotations = var.annotations
  }

  dynamic "aggregation_rule" {
    for_each = var.aggregation_rule != null ? [var.aggregation_rule] : []
    content {
      dynamic "cluster_role_selectors" {
        for_each = aggregation_rule.value.cluster_role_selectors
        content {
          match_labels = try(cluster_role_selectors.value.match_labels, null)

          dynamic "match_expressions" {
            for_each = try(cluster_role_selectors.value.match_expressions, [])
            content {
              key      = match_expressions.value.key
              operator = match_expressions.value.operator
              values   = try(match_expressions.value.values, null)
            }
          }
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      api_groups        = try(rule.value.api_groups, null)
      resources         = try(rule.value.resources, null)
      verbs             = rule.value.verbs
      resource_names    = try(rule.value.resource_names, null)
      non_resource_urls = try(rule.value.non_resource_urls, null)
    }
  }
}
