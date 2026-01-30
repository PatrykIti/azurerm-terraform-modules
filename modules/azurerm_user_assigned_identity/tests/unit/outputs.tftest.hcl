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
      tags = {
        Environment = "Test"
      }
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
  name                = "uai-test"
  resource_group_name = "test-rg"
  location            = "northeurope"
  tags = {
    Environment = "Test"
  }

  federated_identity_credentials = [
    {
      name     = "github-actions"
      issuer   = "https://issuer.example.com"
      subject  = "repo:example-org/example-repo:ref:refs/heads/main"
      audience = ["api://AzureADTokenExchange"]
    }
  ]
}

run "verify_outputs" {
  command = apply

  assert {
    condition     = output.id != null && output.id != ""
    error_message = "ID output should not be empty."
  }

  assert {
    condition     = output.client_id != null && output.client_id != ""
    error_message = "client_id output should not be empty."
  }

  assert {
    condition     = output.principal_id != null && output.principal_id != ""
    error_message = "principal_id output should not be empty."
  }

  assert {
    condition     = output.tenant_id != null && output.tenant_id != ""
    error_message = "tenant_id output should not be empty."
  }

  assert {
    condition     = output.federated_identity_credentials["github-actions"].issuer == "https://issuer.example.com"
    error_message = "Federated identity credentials output should include the issuer."
  }
}
