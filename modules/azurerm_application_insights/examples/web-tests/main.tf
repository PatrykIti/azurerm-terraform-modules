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

locals {
  web_test_xml = <<-XML
    <?xml version="1.0" encoding="utf-8"?>
    <WebTest Name="basic-ping" Id="00000000-0000-0000-0000-000000000000" Enabled="True" Timeout="30" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010">
      <Items>
        <Request Method="GET" Guid="00000000-0000-0000-0000-000000000001" Version="1.1" Url="https://example.com" ThinkTime="0" Timeout="30" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
      </Items>
    </WebTest>
  XML
}

module "application_insights" {
  source = "../../"

  name                = var.application_insights_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"

  web_tests = [
    {
      name          = "basic-ping"
      kind          = "ping"
      frequency     = 300
      timeout       = 30
      enabled       = true
      geo_locations = ["emea-nl-ams-azr"]
      web_test_xml  = local.web_test_xml
    }
  ]

  tags = {
    Environment = "Development"
    Example     = "Web Tests"
  }
}
