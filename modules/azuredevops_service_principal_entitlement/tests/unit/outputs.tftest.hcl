# Test outputs for Azure DevOps service principal entitlement

mock_provider "azuredevops" {
  mock_resource "azuredevops_service_principal_entitlement" {
    defaults = {
      id         = "sp-0003"
      descriptor = "vssps.mock"
    }
  }
}

variables {
  origin_id            = "22222222-2222-2222-2222-222222222222"
  account_license_type = "basic"
  licensing_source     = "account"
}

run "outputs_apply" {
  command = apply

  assert {
    condition     = output.service_principal_entitlement_id == "sp-0003"
    error_message = "service_principal_entitlement_id should return the entitlement ID."
  }

  assert {
    condition     = output.service_principal_entitlement_descriptor == "vssps.mock"
    error_message = "service_principal_entitlement_descriptor should return the entitlement descriptor."
  }
}
