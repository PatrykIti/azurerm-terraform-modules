provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-test-invalid"
  location = "northeurope"
}

module "storage_account" {
  source = "../../../"

  name                     = "stginvalidcont123"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  containers = [
    {
      name = "testcontainer"
      # Invalid: container access type
      container_access_type = "public"
    }
  ]
}