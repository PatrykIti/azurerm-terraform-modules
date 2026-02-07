# Defaults tests for Cognitive Account module

mock_provider "azurerm" {
  mock_resource "azurerm_cognitive_account" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/cogunit"
      name = "cogunit"
    }
  }
  mock_resource "azurerm_cognitive_deployment" {}
  mock_resource "azurerm_cognitive_account_rai_policy" {}
  mock_resource "azurerm_cognitive_account_rai_blocklist" {}
  mock_resource "azurerm_cognitive_account_customer_managed_key" {}
  mock_resource "azurerm_monitor_diagnostic_setting" {}
  mock_data "azurerm_monitor_diagnostic_categories" {}
}

variables {
  name                  = "cogunit"
  resource_group_name   = "test-rg"
  location              = "westeurope"
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "cogunit"
}

run "defaults" {
  command = plan
}
