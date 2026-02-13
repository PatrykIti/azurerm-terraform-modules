# Test group entitlement planning

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
    key                  = "platform-group"
    display_name         = "ADO Platform Team"
    account_license_type = "express"
    licensing_source     = "account"
  }
}

run "group_entitlement_plan" {
  command = plan

  assert {
    condition     = azuredevops_group_entitlement.group_entitlement.display_name == "ADO Platform Team"
    error_message = "display_name should match provided value."
  }

  assert {
    condition     = azuredevops_group_entitlement.group_entitlement.account_license_type == "express"
    error_message = "account_license_type should match provided value."
  }
}
