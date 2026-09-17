# Network integration test fixture (AMPLS access modes)
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-ampls-network-${var.random_suffix}"
  location = var.location
}

module "monitor_private_link_scope" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv3.0.0"

  name                = "ampls-network-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.test.name

  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "Open"

  tags = {
    Environment = "Test"
    Scenario    = "Network"
  }
}
