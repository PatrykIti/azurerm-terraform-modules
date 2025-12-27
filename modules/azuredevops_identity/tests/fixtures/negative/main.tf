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

# This should fail due to conflicting membership selectors
module "azuredevops_identity" {
  source = "../../../"

  groups = {
    bad = {
      display_name = "ado-identity-negative"
    }
  }

  group_memberships = [
    {
      group_descriptor   = "vssgp.invalid"
      group_key          = "bad"
      member_descriptors = ["vssgp.invalid-member"]
    }
  ]
}
