# Negative test cases - should fail validation
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-ampls-negative-test"
  location = "West Europe"
}

# This should fail due to invalid name
module "monitor_private_link_scope" {
  source = "../../../"

  name                = "ampls_invalid" # Should fail validation
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
