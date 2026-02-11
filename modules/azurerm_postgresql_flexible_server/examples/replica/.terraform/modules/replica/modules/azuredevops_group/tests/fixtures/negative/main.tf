terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

# Negative test cases - should fail validation
provider "azuredevops" {}

# This should fail because group_descriptor is provided but empty
module "azuredevops_group" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  group_display_name = "ado-group-negative"

  group_memberships = [
    {
      key                = "missing-group"
      group_descriptor   = ""
      member_descriptors = ["vssgp.invalid-member"]
    }
  ]
}
