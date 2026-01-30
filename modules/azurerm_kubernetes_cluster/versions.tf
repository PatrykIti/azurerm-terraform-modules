terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "1.13.0"
    }
  }
}
