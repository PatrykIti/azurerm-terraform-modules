provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-kubernetes_namespace-basic-example"
  location = "West Europe"
}

module "kubernetes_namespace" {
  source = "../../"

  name                = "kubernetesnamespaceexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
