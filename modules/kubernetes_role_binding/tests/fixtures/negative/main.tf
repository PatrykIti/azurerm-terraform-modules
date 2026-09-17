terraform {
  required_version = ">= 1.12.2"
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.20.0" }
  }
}

provider "kubernetes" {}

module "kubernetes_role_binding" {
  source    = "../../../"
  name      = "intent-resolver-read-users"
  namespace = "intent-resolver"
  role_ref = {
    name = "intent-resolver-read"
  }
  subjects = []
}
