provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-kubernetes_cluster-secure-example"
  location = "West Europe"
}

module "kubernetes_cluster" {
  source = "../../../"

  name                = "kubernetesclusterexample003"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add security-focused configuration here

  tags = {
    Environment = "Production"
    Example     = "Secure"
  }
}
