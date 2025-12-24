# Test outputs for Azure DevOps Service Endpoints

mock_provider "azuredevops" {
  mock_resource "azuredevops_serviceendpoint_generic" {
    defaults = {
      id                    = "endpoint-0001"
      service_endpoint_name = "generic-endpoint"
    }
  }

  mock_resource "azuredevops_serviceendpoint_incomingwebhook" {
    defaults = {
      id                    = "endpoint-0002"
      service_endpoint_name = "webhook-endpoint"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  serviceendpoint_generic = [
    {
      service_endpoint_name = "generic-endpoint"
      server_url            = "https://example.endpoint.local"
      username              = "user"
      password              = "pass"
    }
  ]

  serviceendpoint_incomingwebhook = [
    {
      service_endpoint_name = "webhook-endpoint"
      webhook_name          = "example_webhook"
    }
  ]
}

run "outputs_plan" {
  command = plan

  assert {
    condition     = length(keys(output.serviceendpoint_ids.generic)) == 1
    error_message = "serviceendpoint_ids.generic should include configured endpoints."
  }

  assert {
    condition     = length(keys(output.serviceendpoint_ids.incomingwebhook)) == 1
    error_message = "serviceendpoint_ids.incomingwebhook should include configured endpoints."
  }
}
