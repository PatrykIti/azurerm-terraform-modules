# Test basic service endpoint creation

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  serviceendpoint_generic = {
    service_endpoint_name = "generic-endpoint"
    server_url            = "https://example.endpoint.local"
    username              = "user"
    password              = "pass"
  }
}

run "serviceendpoint_plan" {
  command = plan

  assert {
    condition     = azuredevops_serviceendpoint_generic.generic.service_endpoint_name == "generic-endpoint"
    error_message = "service_endpoint_name should match the input."
  }

  assert {
    condition     = azuredevops_serviceendpoint_generic.generic.server_url == "https://example.endpoint.local"
    error_message = "server_url should match the input."
  }
}
