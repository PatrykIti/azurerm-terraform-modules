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

module "azuredevops_group" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_group?ref=ADOGv1.0.0"

  group_display_name = var.group_name_prefix
  group_description  = "Read-only group for demos"
}
