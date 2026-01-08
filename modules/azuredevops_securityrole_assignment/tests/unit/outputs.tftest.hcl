# Test outputs for Azure DevOps security role assignment

mock_provider "azuredevops" {
  mock_resource "azuredevops_securityrole_assignment" {
    defaults = {
      id = "assignment-0001"
    }
  }
}

variables {
  scope       = "project"
  resource_id = "00000000-0000-0000-0000-000000000000"
  role_name   = "Reader"
  identity_id = "11111111-1111-1111-1111-111111111111"
}

run "outputs_apply" {
  command = apply

  assert {
    condition     = output.securityrole_assignment_id == "assignment-0001"
    error_message = "securityrole_assignment_id should match the mocked ID."
  }
}
