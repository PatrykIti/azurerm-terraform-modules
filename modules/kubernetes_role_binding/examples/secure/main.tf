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

resource "kubernetes_role_v1" "role" {
  metadata {
    name      = "intent-resolver-reader"
    namespace = var.namespace
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }
}

module "kubernetes_role_binding" {
  source = "../../"

  name      = "intent-resolver-reader-sa"
  namespace = var.namespace

  role_ref = {
    kind = "Role"
    name = kubernetes_role_v1.role.metadata[0].name
  }

  subjects = [
    {
      kind      = "ServiceAccount"
      name      = "intent-resolver"
      namespace = var.namespace
    }
  ]
}
