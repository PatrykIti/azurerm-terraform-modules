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

module "azuredevops_serviceendpoint" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_serviceendpoint?ref=ADOSE1.0.0"

  project_id = var.project_id

  serviceendpoint_generic = {
    service_endpoint_name = var.generic_endpoint_name
    server_url            = var.generic_endpoint_url
    username              = var.generic_endpoint_username
    password              = var.generic_endpoint_password
    description           = "Managed by Terraform"
  }
}
