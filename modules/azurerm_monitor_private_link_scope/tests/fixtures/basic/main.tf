provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-ampls-basic-${var.random_suffix}"
  location = var.location
}

module "monitor_private_link_scope" {
  source = "../../.."

  name                = "ampls-basic-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  ingestion_access_mode = var.ingestion_access_mode
  query_access_mode     = var.query_access_mode

  tags = var.tags
}
