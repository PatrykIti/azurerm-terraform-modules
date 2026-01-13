# Test defaults for Azure DevOps user entitlements

mock_provider "azuredevops" {
  mock_resource "azuredevops_user_entitlement" {
    defaults = {
      id         = "user-0001"
      descriptor = "vssps.user"
    }
  }
}

run "default_license_values" {
  command = plan

  variables {
    user_entitlement = {
      principal_name = "user@example.com"
    }
  }

  assert {
    condition     = azuredevops_user_entitlement.user_entitlement.account_license_type == "express"
    error_message = "account_license_type should default to express."
  }

  assert {
    condition     = azuredevops_user_entitlement.user_entitlement.licensing_source == "account"
    error_message = "licensing_source should default to account."
  }
}
