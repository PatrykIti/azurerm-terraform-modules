# Negative test cases - should fail validation
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-kubernetes_cluster-negative-test"
  location = "West Europe"
}

# This should fail due to invalid name
module "kubernetes_cluster" {
  source = "../../../.."

  name                = "INVALID-NAME-WITH-UPPERCASE" # Should fail validation
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
