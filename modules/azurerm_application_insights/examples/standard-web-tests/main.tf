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

  standard_web_tests = [
    {
      name          = "standard-ping"
      description   = "Standard web test for https://example.com"
      frequency     = 300
      timeout       = 30
      enabled       = true
      geo_locations = ["emea-nl-ams-azr"]
      request = {
        url                              = "https://example.com"
        http_verb                        = "GET"
        follow_redirects_enabled         = true
        parse_dependent_requests_enabled = true
        header = [
          {
            name  = "User-Agent"
            value = "Terraform"
          }
        ]
      }
      validation_rules = {
        expected_status_code        = 200
        ssl_check_enabled           = true
        ssl_cert_remaining_lifetime = 7
        content = {
          content_match      = "Example Domain"
          ignore_case        = true
          pass_if_text_found = true
        }
      }
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Standard Web Tests"
  }
}
