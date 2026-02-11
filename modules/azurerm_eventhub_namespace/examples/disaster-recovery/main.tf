# Event Hub Namespace Disaster Recovery Example

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

module "secondary_namespace" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_eventhub_namespace?ref=EHNSv1.0.0"

  name                = var.secondary_namespace_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku = "Standard"

  tags = {
    Environment = "Development"
    Example     = "DisasterRecovery-Secondary"
  }
}

module "primary_namespace" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_eventhub_namespace?ref=EHNSv1.0.0"

  name                = var.primary_namespace_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku = "Standard"

  disaster_recovery_config = {
    name                 = "ehns-dr-config"
    partner_namespace_id = module.secondary_namespace.id
  }

  tags = {
    Environment = "Development"
    Example     = "DisasterRecovery-Primary"
  }
}
