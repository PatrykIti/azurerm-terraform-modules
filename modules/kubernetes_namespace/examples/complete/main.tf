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
    "app.kubernetes.io/name"       = "intent-resolver"
    "app.kubernetes.io/managed-by" = "terraform"
    Environment                    = "Development"
    Example                        = "Complete"
  }

  annotations = {
    "owner.team"       = "genai"
    "support.channel"  = "#platform"
    "example.scenario" = "complete"
  }

  wait_for_default_service_account = true
}
