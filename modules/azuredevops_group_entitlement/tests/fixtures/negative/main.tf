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

# Invalid selector combination: display_name and origin+origin_id together.
module "azuredevops_group_entitlement" {
  source = "../../../"

  group_entitlement = {
    key          = "fixture-negative-group"
    display_name = var.group_display_name
    origin       = var.group_origin
    origin_id    = var.group_origin_id
  }
}
