provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-uai-complete-example"
  location = var.location
}

module "user_assigned_identity" {
  source = "../../"

  name                = "uai-complete-example"
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

  timeouts = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  federated_identity_credential_timeouts = {
    create = "15m"
    delete = "15m"
  }

  tags = {
    Environment = "Development"
    Example     = "Complete"
    Owner       = "platform-team"
  }
}
