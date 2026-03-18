# Test default settings for Azure DevOps Group Entitlement

mock_provider "azuredevops" {
  mock_resource "azuredevops_group_entitlement" {
    defaults = {
      id         = "group-entitlement-0001"
      descriptor = "vssgp.mock.group.entitlement"
    }
  }
}

run "defaults_plan" {
  command = plan

  variables {
    group_entitlement = {
      display_name = "ADO Platform Team"
    }
  }

  assert {
    condition     = azuredevops_group_entitlement.group_entitlement.account_license_type == "express"
    error_message = "account_license_type should default to express."
  }

  assert {
    condition     = azuredevops_group_entitlement.group_entitlement.licensing_source == "account"
    error_message = "licensing_source should default to account."
  }
}
