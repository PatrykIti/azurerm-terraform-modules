provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-test-invalid"
  location = "northeurope"
}

module "storage_account" {
  source = "../../../"
  
  name                     = "stginvalidtier123"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  # Invalid: account tier must be Standard or Premium
  account_tier             = "Basic"
  account_replication_type = "LRS"
}