provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-ampls-complete-${var.random_suffix}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-ampls-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "example" {
  name                = "appi-ampls-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

resource "azurerm_monitor_data_collection_endpoint" "example" {
  name                = "dce-ampls-${var.random_suffix}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "Linux"
}

module "monitor_private_link_scope" {
  source = "../../.."

  name                = "ampls-complete-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name

  ingestion_access_mode = "PrivateOnly"
  query_access_mode     = "Open"

  scoped_services = [
    {
      name               = "ampls-law-${var.random_suffix}"
      linked_resource_id = azurerm_log_analytics_workspace.example.id
    },
    {
      name               = "ampls-appi-${var.random_suffix}"
      linked_resource_id = azurerm_application_insights.example.id
    },
    {
      name               = "ampls-dce-${var.random_suffix}"
      linked_resource_id = azurerm_monitor_data_collection_endpoint.example.id
    }
  ]

  tags = {
    Environment = "Test"
    TestType    = "Complete"
    CostCenter  = "Engineering"
    Owner       = "terratest"
  }
}
