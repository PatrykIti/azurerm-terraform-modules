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

module "kubernetes_namespace" {
  source = "../../"

  name = var.namespace_name

  labels = {
    Environment = "Production"
    Example     = "Secure"
  }

  annotations = {
    "owner.team"                         = "platform"
    "pod-security.kubernetes.io/enforce" = "restricted"
    "pod-security.kubernetes.io/audit"   = "restricted"
    "pod-security.kubernetes.io/warn"    = "restricted"
  }

  wait_for_default_service_account = true
}
