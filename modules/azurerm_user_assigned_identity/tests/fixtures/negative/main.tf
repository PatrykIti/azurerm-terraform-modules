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
  name     = "rg-uai-negative-test"
  location = "westeurope"
}

# This configuration should fail validation
module "user_assigned_identity" {
  source = "../../../"

  name                = "uai-negative-test"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  federated_identity_credentials = [
    {
      name     = "invalid*name"
      issuer   = "http://invalid-issuer"
      subject  = ""
      audience = []
    }
  ]
}
