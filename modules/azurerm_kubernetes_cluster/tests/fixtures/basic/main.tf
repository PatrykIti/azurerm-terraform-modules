provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-kubernetes_cluster-basic-example"
  location = "West Europe"
}

module "kubernetes_cluster" {
  source = "../../.."

  name                = "kubernetesclusterexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
