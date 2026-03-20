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

  name      = "intent-resolver-read-portforward"
  namespace = var.namespace

  rules = [
    {
      api_groups = [""]
      resources  = ["pods", "services", "endpoints"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups     = [""]
      resources      = ["pods/portforward"]
      verbs          = ["create"]
      resource_names = ["intent-resolver-api"]
    }
  ]
}
