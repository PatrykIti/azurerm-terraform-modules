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

module "azuredevops_variable_groups" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  project_id = var.project_id
  name       = "${var.group_name_prefix}-basic"

  description  = "Basic variable group"
  allow_access = true

  variables = [
    {
      name  = "environment"
      value = "test"
    }
  ]
}
