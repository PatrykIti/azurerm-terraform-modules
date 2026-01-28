provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-ampls-basic-${var.random_suffix}"
  location = var.location
}

module "monitor_private_link_scope" {
  source = "../../.."

  name                = "ampls-basic-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Test"
    Example     = "Basic"
  }
}
