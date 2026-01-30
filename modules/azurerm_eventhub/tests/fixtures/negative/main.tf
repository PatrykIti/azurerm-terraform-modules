# Negative test cases - should fail validation
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

resource "azurerm_resource_group" "test" {
  name     = "rg-eh-negative-test"
  location = "West Europe"
}

# This should fail due to missing namespace input
module "eventhub" {
  source = "../../../"

  name            = "ehnegative"
  partition_count = 2
}
