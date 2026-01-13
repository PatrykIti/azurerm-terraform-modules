# Test naming logic for Azure DevOps user entitlements

mock_provider "azuredevops" {
  mock_resource "azuredevops_user_entitlement" {
    defaults = {
      id         = "user-0001"
      descriptor = "vssps.user"
    }
  }
}

run "explicit_key" {
  command = apply

  variables {
    user_entitlement = {
      key            = "explicit-key"
      principal_name = "user@example.com"
    }
  }

  assert {
    condition     = output.user_entitlement_key == "explicit-key"
    error_message = "user_entitlement_key should prefer explicit key values."
  }
}

run "principal_name_key" {
  command = apply

  variables {
    user_entitlement = {
      principal_name = "user@example.com"
    }
  }

  assert {
    condition     = output.user_entitlement_key == "user@example.com"
    error_message = "user_entitlement_key should fall back to principal_name."
  }
}

run "origin_id_key" {
  command = apply

  variables {
    user_entitlement = {
      origin    = "aad"
      origin_id = "11111111-1111-1111-1111-111111111111"
    }
  }

  assert {
    condition     = output.user_entitlement_key == "11111111-1111-1111-1111-111111111111"
    error_message = "user_entitlement_key should fall back to origin_id."
  }
}
