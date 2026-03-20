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
    name = "intent-resolver-cluster-discovery"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "services", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }
}

module "kubernetes_cluster_role_binding" {
  source = "../../"

  name = "intent-resolver-cluster-discovery-users"

  role_ref = {
    name = kubernetes_cluster_role_v1.role.metadata[0].name
  }

  subjects = [
    {
      kind = "User"
      name = var.user_object_id_1
    },
    {
      kind = "User"
      name = var.user_object_id_2
    }
  ]
}
