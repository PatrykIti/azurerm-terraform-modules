terraform {
  required_version = ">= 1.12.2"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}

provider "kubernetes" {}

resource "kubernetes_cluster_role_v1" "role" {
  metadata {
    name = "observability-read-only"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

module "kubernetes_cluster_role_binding" {
  source = "../../"

  name = "observability-read-only-sa"

  role_ref = {
    name = kubernetes_cluster_role_v1.role.metadata[0].name
  }

  subjects = [
    {
      kind      = "ServiceAccount"
      name      = "observability-reader"
      namespace = var.namespace
    }
  ]
}
