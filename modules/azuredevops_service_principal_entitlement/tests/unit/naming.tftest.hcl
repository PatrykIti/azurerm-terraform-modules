# Test entitlement planning

mock_provider "azuredevops" {
  mock_resource "azuredevops_service_principal_entitlement" {
    defaults = {
      id         = "sp-0002"
      descriptor = "vssps.mock"
    }
  }
}

variables {
  origin_id            = "11111111-1111-1111-1111-111111111111"
  account_license_type = "basic"
  licensing_source     = "account"
}

run "entitlement_plan" {
  command = plan

  assert {
    condition     = azuredevops_service_principal_entitlement.service_principal_entitlement.origin_id == "11111111-1111-1111-1111-111111111111"
    error_message = "origin_id should be mapped to the entitlement resource."
  }
}
