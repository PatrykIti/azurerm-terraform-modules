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

module "kubernetes_cluster_role" {
  source = "../../"

  name = "namespace-and-pod-discovery"

  rules = [
    {
      api_groups = [""]
      resources  = ["namespaces", "pods"]
      verbs      = ["get", "list", "watch"]
    },
    {
      non_resource_urls = ["/api", "/api/*", "/healthz"]
      verbs             = ["get"]
    }
  ]
}
