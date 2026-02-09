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

  mock_resource "azurerm_federated_identity_credential" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-test/federatedIdentityCredentials/github-actions"
      name                = "github-actions"
      issuer              = "https://issuer.example.com"
      subject             = "repo:example-org/example-repo:ref:refs/heads/main"
      audience            = ["api://AzureADTokenExchange"]
      resource_group_name = "test-rg"
      parent_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-test"
    }
  }
}

variables {
  resource_group_name = "test-rg"
  location            = "northeurope"
}

run "valid_uai_name" {
  command = plan

  variables {
    name = "uai-test_name-01"
  }

  assert {
    condition     = azurerm_user_assigned_identity.user_assigned_identity.name == "uai-test_name-01"
    error_message = "User Assigned Identity name should match the input."
  }
}

run "valid_fic_name" {
  command = plan

  variables {
    name = "uai-test-02"
    federated_identity_credentials = [
      {
        name     = "github-actions"
        issuer   = "https://issuer.example.com"
        subject  = "repo:example-org/example-repo:ref:refs/heads/main"
        audience = ["api://AzureADTokenExchange"]
      }
    ]
  }

  assert {
    condition     = azurerm_federated_identity_credential.federated_identity_credential["github-actions"].name == "github-actions"
    error_message = "Federated identity credential name should match the input."
  }
}
