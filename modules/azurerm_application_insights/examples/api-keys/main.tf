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
  name     = var.resource_group_name
  location = var.location
}

module "application_insights" {
  source = "../../"

  name                = var.application_insights_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"

  api_keys = [
    {
      name             = "read-only"
      read_permissions = ["api"]
    },
    {
      name              = "read-write"
      read_permissions  = ["api"]
      write_permissions = ["annotations"]
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "API Keys"
  }
}
