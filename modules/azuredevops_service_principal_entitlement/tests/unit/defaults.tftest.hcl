# Test defaults for Azure DevOps service principal entitlements

mock_provider "azuredevops" {
  mock_resource "azuredevops_service_principal_entitlement" {
    defaults = {
      id         = "sp-0001"
      descriptor = "vssps.mock"
    }
  }
}

run "no_entitlements_by_default" {
  command = plan

  assert {
    condition     = length(azuredevops_service_principal_entitlement.service_principal_entitlement) == 0
    error_message = "No service principal entitlements should be created by default."
  }
}

run "entitlement_keys" {
  command = apply

  variables {
    service_principal_entitlements = [
      {
        key                  = "platform-sp"
        origin_id            = "00000000-0000-0000-0000-000000000000"
        account_license_type = "basic"
        licensing_source     = "account"
      }
    ]
  }

  assert {
    condition     = contains(keys(azuredevops_service_principal_entitlement.service_principal_entitlement), "platform-sp")
    error_message = "service_principal_entitlements should be keyed by the provided key."
  }
}
