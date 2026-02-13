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

# Invalid membership entry: key is empty string.
module "azuredevops_group" {
  source = "../../../"

  group_display_name = "ado-group-negative"

  group_memberships = [
    {
      key                = ""
      member_descriptors = ["vssgp.invalid-member"]
    }
  ]
}
