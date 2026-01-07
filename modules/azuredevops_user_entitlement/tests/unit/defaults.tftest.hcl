# Test defaults for Azure DevOps user entitlements

mock_provider "azuredevops" {
  mock_resource "azuredevops_user_entitlement" {
    defaults = {
      id         = "user-0001"
      descriptor = "vssps.user"
    }
  }
}

run "no_entitlements_by_default" {
  command = plan

  assert {
    condition     = length(azuredevops_user_entitlement.user_entitlement) == 0
    error_message = "No user entitlements should be created by default."
  }
}

run "entitlement_keys" {
  command = apply

  variables {
    user_entitlements = [
      {
        key                  = "platform-user"
        principal_name       = "user@example.com"
        account_license_type = "basic"
        licensing_source     = "account"
      }
    ]
  }

  assert {
    condition     = contains(keys(azuredevops_user_entitlement.user_entitlement), "platform-user")
    error_message = "user_entitlements should be keyed by the provided key."
  }
}
