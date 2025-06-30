provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-storage-simple-example"
  location = "West Europe"
}

module "storage_account" {
  source = "../../"

  name                     = "stexamplesimple001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}