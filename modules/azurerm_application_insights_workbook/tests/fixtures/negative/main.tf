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
  name     = "rg-application_insights_workbook-negative-test"
  location = var.location
}

locals {
  workbook_data = {
    version = "Notebook/1.0"
    items   = []
  }
}

# This should fail due to invalid name
module "application_insights_workbook" {
  source = "../../../"

  name                = "INVALID-NAME" # Should fail UUID validation
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  display_name        = "Invalid Workbook"
  data_json           = jsonencode(local.workbook_data)

  tags = {
    Environment = "Test"
    Scenario    = "Negative"
  }
}
