# Test variable validation for Azure DevOps Service Endpoint (Generic)

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"

  serviceendpoint_generic = {
    service_endpoint_name = "generic-endpoint"
    server_url            = "https://example.endpoint.local"
  }
}

run "invalid_permissions_duplicate_key" {
  command = plan

  variables {
    serviceendpoint_permissions = [
      {
        principal = "vssgp.duplicate"
        permissions = {
          Use = "Allow"
        }
      },
      {
        principal = "vssgp.duplicate"
        permissions = {
          Use = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.serviceendpoint_permissions,
  ]
}

run "invalid_permissions_value" {
  command = plan

  variables {
    serviceendpoint_permissions = [
      {
        principal = "vssgp.invalid"
        permissions = {
          Use = "Maybe"
        }
      }
    ]
  }

  expect_failures = [
    var.serviceendpoint_permissions,
  ]
}

run "invalid_permissions_empty_map" {
  command = plan

  variables {
    serviceendpoint_permissions = [
      {
        principal   = "vssgp.invalid"
        permissions = {}
      }
    ]
  }

  expect_failures = [
    var.serviceendpoint_permissions,
  ]
}

run "invalid_generic_empty_name" {
  command = plan

  variables {
    serviceendpoint_generic = {
      service_endpoint_name = " "
      server_url            = "https://example.endpoint.local"
    }
  }

  expect_failures = [
    var.serviceendpoint_generic,
  ]
}

run "invalid_generic_empty_server_url" {
  command = plan

  variables {
    serviceendpoint_generic = {
      service_endpoint_name = "generic-endpoint"
      server_url            = " "
    }
  }

  expect_failures = [
    var.serviceendpoint_generic,
  ]
}
