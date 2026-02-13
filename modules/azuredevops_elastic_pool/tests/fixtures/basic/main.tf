terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}
provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_elastic_pool" {
  source = "../../../"

  name                   = "${var.elastic_pool_name_prefix}-${random_string.suffix.result}"
  service_endpoint_id    = var.service_endpoint_id
  service_endpoint_scope = var.service_endpoint_scope
  azure_resource_id      = var.azure_resource_id
}
