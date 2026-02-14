# Test default settings for Azure DevOps Service Endpoint (Generic)

mock_provider "azuredevops" {
  mock_resource "azuredevops_serviceendpoint_generic" {
    defaults = {
      id                    = "endpoint-0001"
      service_endpoint_name = "generic-endpoint"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  serviceendpoint_generic = {
    service_endpoint_name = "generic-endpoint"
    server_url            = "https://example.endpoint.local"
  }
}

run "defaults_plan" {
  command = plan

  assert {
    condition     = azuredevops_serviceendpoint_generic.generic.service_endpoint_name == "generic-endpoint"
    error_message = "The generic service endpoint should be created with the provided name."
  }

  assert {
    condition     = length(azuredevops_serviceendpoint_permissions.permissions) == 0
    error_message = "No service endpoint permissions should be created by default."
  }
}
