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

module "kubernetes_role" {
  source = "../../"

  name      = "intent-resolver-read"
  namespace = var.namespace

  rules = [
    {
      api_groups = [""]
      resources  = ["pods", "services", "endpoints"]
      verbs      = ["get", "list", "watch"]
    }
  ]
}
