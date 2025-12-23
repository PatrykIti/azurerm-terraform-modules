# Role assignment test fixture (optional inputs)
provider "azuredevops" {}

module "azuredevops_identity" {
  source = "../../../"

  groups = {
    auditors = {
      display_name = "ado-identity-role-fixture"
      description  = "Role assignment fixture group"
    }
  }

  securityrole_assignments = var.security_role_assignments
}
