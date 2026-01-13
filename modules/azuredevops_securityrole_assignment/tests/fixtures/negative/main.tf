terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

# Negative test case - should fail validation
provider "azuredevops" {}

module "azuredevops_securityrole_assignment" {
  source = "../../../"

  scope       = "00000000-0000-0000-0000-000000000000"
  resource_id = "00000000-0000-0000-0000-000000000000"
  role_name   = "Reader"
  identity_id = ""
}
