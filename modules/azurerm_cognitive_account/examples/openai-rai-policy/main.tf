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

module "cognitive_account" {
  source = "../.."

  name                = var.account_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "OpenAI"
  sku_name = "S0"

  public_network_access_enabled = true
  local_auth_enabled            = true

  rai_policies = [
    {
      name             = "custom-policy"
      base_policy_name = "Microsoft.Default"
      mode             = "Default"
      content_filters = [
        {
          name               = "Hate"
          filter_enabled     = true
          block_enabled      = true
          severity_threshold = "High"
          source             = "Prompt"
        }
      ]
      tags = {
        Example = "RAI Policy"
      }
    }
  ]

  tags = var.tags
}
