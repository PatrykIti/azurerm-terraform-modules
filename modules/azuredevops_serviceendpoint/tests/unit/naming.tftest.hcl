# Test basic service endpoint creation

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  serviceendpoint_generic = [
    {
      key                   = "generic-key"
      service_endpoint_name = "generic-endpoint"
      server_url            = "https://example.endpoint.local"
      username              = "user"
      password              = "pass"
    }
  ]
}

run "serviceendpoint_plan" {
  command = plan

  assert {
    condition     = length(azuredevops_serviceendpoint_generic.generic) == 1
    error_message = "serviceendpoint_generic should create one endpoint."
  }
}
