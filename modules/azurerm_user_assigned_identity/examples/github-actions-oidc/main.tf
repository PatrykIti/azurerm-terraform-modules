provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-uai-github-actions-oidc"
  location = var.location
}

module "user_assigned_identity" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_user_assigned_identity?ref=UAIv1.0.0"

  name                = "uai-github-actions"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  federated_identity_credentials = [
    {
      name     = "github-actions"
      issuer   = "https://token.actions.githubusercontent.com"
      subject  = "repo:${var.github_repository}:ref:${var.github_ref}"
      audience = ["api://AzureADTokenExchange"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "GitHubActionsOIDC"
  }
}
