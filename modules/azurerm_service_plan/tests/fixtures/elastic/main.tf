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

locals {
  suffix              = substr(var.random_suffix, 0, 8)
  resource_group_name = "rg-asp-elastic-${local.suffix}"
  service_plan_name   = "asp-elastic-${local.suffix}"
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = var.location
}

module "service_plan" {
  source = "../../../"

  name                = local.service_plan_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  service_plan = {
    os_type                      = "Linux"
    sku_name                     = "EP1"
    maximum_elastic_worker_count = 20
  }

  tags = {
    Environment = "Test"
    Example     = "Elastic"
  }
}
