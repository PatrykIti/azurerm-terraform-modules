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

module "azuredevops_agent_pools" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_agent_pools?ref=ADOAP1.0.0"

  name = var.pool_name
}
