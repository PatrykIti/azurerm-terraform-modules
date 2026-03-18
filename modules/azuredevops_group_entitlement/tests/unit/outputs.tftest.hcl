# Test outputs for Azure DevOps Group Entitlement

mock_provider "azuredevops" {
  mock_resource "azuredevops_group_entitlement" {
    defaults = {
      id         = "group-entitlement-0001"
      descriptor = "vssgp.mock.group.entitlement"
    }
  }
}

variables {
  group_entitlement = {
    key          = "platform-group"
    display_name = "ADO Platform Team"
  }
}

run "outputs_apply" {
  command = apply

  assert {
    condition     = output.group_entitlement_id == "group-entitlement-0001"
    error_message = "group_entitlement_id should match the mock ID."
  }

  assert {
    condition     = output.group_entitlement_descriptor == "vssgp.mock.group.entitlement"
    error_message = "group_entitlement_descriptor should match the mock descriptor."
  }

  assert {
    condition     = output.group_entitlement_key == "platform-group"
    error_message = "group_entitlement_key should match explicit key."
  }
}
