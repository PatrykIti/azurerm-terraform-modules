mock_provider "azurerm" {
  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-test"
      name                = "uai-test"
      location            = "northeurope"
      resource_group_name = "test-rg"
      client_id           = "00000000-0000-0000-0000-000000000000"
      principal_id        = "11111111-1111-1111-1111-111111111111"
      tenant_id           = "22222222-2222-2222-2222-222222222222"
      tags                = {}
    }
  }
}

variables {
  name                = "uai-test"
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "defaults_apply" {
  command = apply

  assert {
    condition     = output.tags == {}
    error_message = "Default tags should be an empty map."
  }

  assert {
    condition     = length(keys(output.federated_identity_credentials)) == 0
    error_message = "No federated identity credentials should be created by default."
  }
}
