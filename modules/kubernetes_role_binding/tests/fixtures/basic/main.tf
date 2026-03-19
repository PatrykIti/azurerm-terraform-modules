provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-kubernetes_role_binding-basic-example"
  location = "West Europe"
}

module "kubernetes_role_binding" {
  source = "../../"

  name                = "kubernetesrolebindingexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
