provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-kubernetes_secrets-secure-example"
  location = "West Europe"
}

module "kubernetes_secrets" {
  source = "../../"

  name                = "kubernetessecretsexample003"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add security-focused configuration here

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
