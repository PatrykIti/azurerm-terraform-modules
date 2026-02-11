provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-uai-basic-example"
  location = var.location
}

module "user_assigned_identity" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_user_assigned_identity?ref=UAIv1.0.0"

  name                = "uai-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
