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

  # Enable shared access keys for simple example to allow user access
  security_settings = {
    shared_access_key_enabled = true
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}