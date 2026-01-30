provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-ampls-secure-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-ampls-secure-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "monitor_private_link_scope" {
  source = "../../.."

  name                = "ampls-secure-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name

  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "PrivateOnly"

  scoped_services = [
    {
      name               = "ampls-law-${var.random_suffix}"
      linked_resource_id = azurerm_log_analytics_workspace.example.id
    }
  ]

  tags = {
    Environment = "Test"
    TestType    = "Secure"
    Owner       = "terratest"
  }
}
