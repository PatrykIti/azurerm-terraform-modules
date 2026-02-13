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

module "azuredevops_elastic_pool" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_elastic_pool?ref=ADOEPv1.0.0"

  name                   = var.elastic_pool_name
  service_endpoint_id    = var.service_endpoint_id
  service_endpoint_scope = var.service_endpoint_scope
  azure_resource_id      = var.azure_resource_id
}
