terraform {
  required_version = ">= 1.12.2"
  required_providers { kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.20.0" } }
}
provider "kubernetes" {}
module "kubernetes_cluster_role" {
  source = "../../../"
  name   = "namespace-reader"
  rules  = []
}
