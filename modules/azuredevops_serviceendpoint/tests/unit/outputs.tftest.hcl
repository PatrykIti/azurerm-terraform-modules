# Test outputs for Azure DevOps Service Endpoint (Generic)

mock_provider "azuredevops" {
  mock_resource "azuredevops_serviceendpoint_generic" {
    defaults = {
      id                    = "11111111-1111-1111-1111-111111111111"
      service_endpoint_name = "generic-endpoint"
    }
  }

  mock_resource "azuredevops_serviceendpoint_permissions" {
    defaults = {
      id = "permission-0001"
    }
  }
}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  serviceendpoint_generic = {
    service_endpoint_name = "generic-endpoint"
    server_url            = "https://example.endpoint.local"
  }

  serviceendpoint_permissions = [
    {
      principal = "vssgp.valid"
      permissions = {
        Use = "Allow"
      }
    }
  ]
}

run "outputs_apply" {
  command = apply

  assert {
    condition     = output.serviceendpoint_id == "11111111-1111-1111-1111-111111111111"
    error_message = "serviceendpoint_id should match the mocked ID."
  }

  assert {
    condition     = nonsensitive(output.serviceendpoint_name) == "generic-endpoint"
    error_message = "serviceendpoint_name should match the mocked name."
  }

  assert {
    condition     = output.permissions["vssgp.valid"] == "permission-0001"
    error_message = "permissions output should include the permission key."
  }
}
