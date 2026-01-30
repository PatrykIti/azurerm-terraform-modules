terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-uai-fic-${var.random_suffix}"
  location = var.location
}

module "user_assigned_identity" {
  source = "../../../"

  name                = "uai-fic-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  federated_identity_credentials = [
    {
      name     = "github-actions-${var.random_suffix}"
      issuer   = "https://token.actions.githubusercontent.com"
      subject  = "repo:example-org/example-repo:ref:refs/heads/main"
      audience = ["api://AzureADTokenExchange"]
    },
    {
      name     = "kubernetes-${var.random_suffix}"
      issuer   = "https://issuer.example.com"
      subject  = "system:serviceaccount:default:app"
      audience = ["api://AzureADTokenExchange"]
    }
  ]

  tags = var.tags
}
