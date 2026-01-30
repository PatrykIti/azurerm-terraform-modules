provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-uai-fic-example"
  location = var.location
}

module "user_assigned_identity" {
  source = "../../"

  name                = "uai-fic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  federated_identity_credentials = [
    {
      name     = "github-actions"
      issuer   = "https://token.actions.githubusercontent.com"
      subject  = "repo:example-org/example-repo:ref:refs/heads/main"
      audience = ["api://AzureADTokenExchange"]
    },
    {
      name     = "kubernetes-oidc"
      issuer   = "https://issuer.example.com"
      subject  = "system:serviceaccount:default:app"
      audience = ["api://AzureADTokenExchange"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "FederatedCredentials"
  }
}
