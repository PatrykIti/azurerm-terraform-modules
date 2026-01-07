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
  source = "../../"

  group_display_name = var.group_name_prefix
  group_description  = "Read-only group for demos"
}
