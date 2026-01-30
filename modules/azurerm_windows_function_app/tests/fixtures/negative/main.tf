# Negative test cases - should fail validation
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-windows_function_app-negative-test"
  location = "West Europe"
}

# This should fail due to invalid name
module "windows_function_app" {
  source = "../../../"

  name                = "INVALID-NAME-WITH-UPPERCASE"  # Should fail validation
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
