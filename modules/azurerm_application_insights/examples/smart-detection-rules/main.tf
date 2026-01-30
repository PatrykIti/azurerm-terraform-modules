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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_application_insights?ref=APPINSv1.0.0"

  name                = var.application_insights_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"

  smart_detection_rules = [
    {
      name    = "Slow server response time"
      enabled = true
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Smart Detection Rules"
  }
}
