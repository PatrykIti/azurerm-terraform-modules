# Azure DevOps Security Role Assignment

locals {
  securityrole_assignments = {
    for assignment in var.securityrole_assignments :
    coalesce(
      assignment.key,
      "${assignment.scope}/${assignment.resource_id}/${assignment.role_name}/${assignment.identity_id}"
    ) => assignment
  }
}

resource "azuredevops_securityrole_assignment" "securityrole_assignment" {
  for_each = local.securityrole_assignments

  scope       = each.value.scope
  resource_id = each.value.resource_id
  identity_id = each.value.identity_id
  role_name   = each.value.role_name
}
