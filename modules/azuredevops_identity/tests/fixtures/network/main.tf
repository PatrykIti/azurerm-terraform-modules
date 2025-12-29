terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

# Role assignment test fixture (optional inputs)
provider "azuredevops" {}

module "azuredevops_identity" {
  source = "../../../"

  group_display_name = "ado-identity-role-fixture"
  group_description  = "Role assignment fixture group"

  securityrole_assignments = var.security_role_assignments
}
