terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-appins-analytics-${var.random_suffix}"
  location = var.location
}

module "application_insights" {
  source = "../../.."

  name                = "appi-analytics-${var.random_suffix}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"

  analytics_items = [
    {
      name    = "requests-over-time"
      type    = "query"
      scope   = "shared"
      content = <<-QUERY
        requests
        | summarize count() by bin(timestamp, 5m)
        | order by timestamp asc
      QUERY
    }
  ]

  tags = var.tags
}
