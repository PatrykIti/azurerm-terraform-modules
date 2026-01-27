# Output tests for Monitor Data Collection Endpoint module

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_data_collection_endpoint" {
    defaults = {
      id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/dataCollectionEndpoints/dceunit"
      name                          = "dceunit"
      location                      = "northeurope"
      resource_group_name           = "test-rg"
      configuration_access_endpoint = "https://config.example"
      logs_ingestion_endpoint       = "https://logs.example"
      metrics_ingestion_endpoint    = "https://metrics.example"
      immutable_id                  = "00000000-0000-0000-0000-000000000000"
      tags = {
        Environment = "Test"
        Module      = "DCE"
      }
    }
  }

  mock_resource "azurerm_monitor_diagnostic_setting" {}
}

variables {
  name                = "dceunit"
  resource_group_name = "test-rg"
  location            = "northeurope"
  tags = {
    Environment = "Test"
    Module      = "DCE"
  }
}

run "verify_basic_outputs" {
  command = apply

  assert {
    condition     = output.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/dataCollectionEndpoints/dceunit"
    error_message = "Output 'id' should return the endpoint ID."
  }

  assert {
    condition     = output.name == "dceunit"
    error_message = "Output 'name' should return the endpoint name."
  }

  assert {
    condition     = output.location == "northeurope"
    error_message = "Output 'location' should return the endpoint location."
  }

  assert {
    condition     = output.resource_group_name == "test-rg"
    error_message = "Output 'resource_group_name' should return the resource group name."
  }

  assert {
    condition     = output.configuration_access_endpoint == "https://config.example"
    error_message = "Output 'configuration_access_endpoint' should return the configuration endpoint."
  }
}

run "verify_tags_output" {
  command = plan

  assert {
    condition     = output.tags["Environment"] == "Test"
    error_message = "Output 'tags' should include Environment tag."
  }

  assert {
    condition     = output.tags["Module"] == "DCE"
    error_message = "Output 'tags' should include Module tag."
  }
}
