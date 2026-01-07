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

# This should fail because no module group is configured and group_descriptor is missing
module "azuredevops_group" {
  source = "../../../"

  group_memberships = [
    {
      key                = "missing-group"
      member_descriptors = ["vssgp.invalid-member"]
    }
  ]
}
