# Test outputs for Azure DevOps user entitlements

mock_provider "azuredevops" {
  mock_resource "azuredevops_user_entitlement" {
    defaults = {
      id         = "user-0001"
      descriptor = "vssps.user"
    }
  }
}

variables {
  user_entitlement = {
    key            = "outputs-user"
    principal_name = "user@example.com"
  }
}

run "outputs_plan" {
  command = apply

  assert {
    condition     = output.user_entitlement_id != null
    error_message = "user_entitlement_id should be present."
  }

  assert {
    condition     = output.user_entitlement_descriptor != null
    error_message = "user_entitlement_descriptor should be present."
  }

  assert {
    condition     = output.user_entitlement_key == "outputs-user"
    error_message = "user_entitlement_key should reflect the configured key."
  }
}
