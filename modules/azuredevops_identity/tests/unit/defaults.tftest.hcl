# Test default settings for Azure DevOps Identity

mock_provider "azuredevops" {}

run "defaults_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_group.group) == 0
    error_message = "No groups should be created by default."
  }

  assert {
    condition     = length(azuredevops_group_membership.group_membership) == 0
    error_message = "No group memberships should be created by default."
  }

  assert {
    condition     = length(azuredevops_group_entitlement.group_entitlement) == 0
    error_message = "No group entitlements should be created by default."
  }

  assert {
    condition     = length(azuredevops_user_entitlement.user_entitlement) == 0
    error_message = "No user entitlements should be created by default."
  }

  assert {
    condition     = length(azuredevops_service_principal_entitlement.service_principal_entitlement) == 0
    error_message = "No service principal entitlements should be created by default."
  }

  assert {
    condition     = length(azuredevops_securityrole_assignment.securityrole_assignment) == 0
    error_message = "No security role assignments should be created by default."
  }
}
