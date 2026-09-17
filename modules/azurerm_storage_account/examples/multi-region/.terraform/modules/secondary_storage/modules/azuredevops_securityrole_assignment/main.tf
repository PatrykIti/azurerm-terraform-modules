# Azure DevOps Security Role Assignment (single resource)

resource "azuredevops_securityrole_assignment" "securityrole_assignment" {
  scope       = var.scope
  resource_id = var.resource_id
  identity_id = var.identity_id
  role_name   = var.role_name
}
