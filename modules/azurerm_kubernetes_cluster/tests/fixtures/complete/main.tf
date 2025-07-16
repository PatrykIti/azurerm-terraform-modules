provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-kubernetes_cluster-complete-example"
  location = "West Europe"
}

module "kubernetes_cluster" {
  source = "../../../"

  name                = "kubernetesclusterexample002"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Add more comprehensive configuration here

  tags = {
    Environment = "Development"
    Example     = "Complete"
  }
}
