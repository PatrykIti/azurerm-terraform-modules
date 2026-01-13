# Test defaults for Azure DevOps service principal entitlement

mock_provider "azuredevops" {
  mock_resource "azuredevops_service_principal_entitlement" {
    defaults = {
      id         = "sp-0001"
      descriptor = "vssps.mock"
    }
  }
}

run "defaults_applied" {
  command = plan

  variables {
    origin_id = "00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = azuredevops_service_principal_entitlement.service_principal_entitlement.origin == "aad"
    error_message = "origin should default to aad."
  }

  assert {
    condition     = azuredevops_service_principal_entitlement.service_principal_entitlement.account_license_type == "express"
    error_message = "account_license_type should default to express."
  }

  assert {
    condition     = azuredevops_service_principal_entitlement.service_principal_entitlement.licensing_source == "account"
    error_message = "licensing_source should default to account."
  }
}
