provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-kubernetes_cluster_role_binding-basic-example"
  location = "West Europe"
}

module "kubernetes_cluster_role_binding" {
  source = "../../"

  name                = "kubernetesclusterrolebindingexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
