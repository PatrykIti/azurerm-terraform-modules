provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-uai-secure-example"
  location = var.location
}

module "user_assigned_identity" {
  source = "../../"

  name                = "uai-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  federated_identity_credentials = [
    {
      name     = "github-actions"
      issuer   = "https://token.actions.githubusercontent.com"
      subject  = "repo:example-org/example-repo:ref:refs/heads/main"
      audience = ["api://AzureADTokenExchange"]
    }
  ]

  tags = {
    Environment = "Production"
    Example     = "Secure"
    Owner       = "platform-team"
  }
}

# Example of least-privilege access outside the module
resource "azurerm_role_assignment" "rg_reader" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Reader"
  principal_id         = module.user_assigned_identity.principal_id
}
