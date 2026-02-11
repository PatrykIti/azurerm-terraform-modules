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

run "invalid_uai_name" {
  command = plan

  variables {
    name = "_bad"
  }

  expect_failures = [
    var.name
  ]
}

run "duplicate_fic_names" {
  command = plan

  variables {
    name = "uai-test-dup"
    federated_identity_credentials = [
      {
        name     = "duplicate"
        issuer   = "https://issuer.example.com"
        subject  = "subject-a"
        audience = ["api://AzureADTokenExchange"]
      },
      {
        name     = "duplicate"
        issuer   = "https://issuer.example.com"
        subject  = "subject-b"
        audience = ["api://AzureADTokenExchange"]
      }
    ]
  }

  expect_failures = [
    var.federated_identity_credentials
  ]
}

run "invalid_issuer" {
  command = plan

  variables {
    name = "uai-test-issuer"
    federated_identity_credentials = [
      {
        name     = "bad-issuer"
        issuer   = "http://issuer.example.com"
        subject  = "subject"
        audience = ["api://AzureADTokenExchange"]
      }
    ]
  }

  expect_failures = [
    var.federated_identity_credentials
  ]
}

run "empty_subject" {
  command = plan

  variables {
    name = "uai-test-subject"
    federated_identity_credentials = [
      {
        name     = "empty-subject"
        issuer   = "https://issuer.example.com"
        subject  = ""
        audience = ["api://AzureADTokenExchange"]
      }
    ]
  }

  expect_failures = [
    var.federated_identity_credentials
  ]
}

run "empty_audience" {
  command = plan

  variables {
    name = "uai-test-audience"
    federated_identity_credentials = [
      {
        name     = "empty-audience"
        issuer   = "https://issuer.example.com"
        subject  = "subject"
        audience = []
      }
    ]
  }

  expect_failures = [
    var.federated_identity_credentials
  ]
}
