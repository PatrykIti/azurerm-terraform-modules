# Test variable validation for Azure DevOps Environments

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "ado-env-validation"
}

run "invalid_name" {
  command = plan

  variables {
    name = "   "
  }

  expect_failures = [
    var.name,
  ]
}

run "invalid_target_resource_type" {
  command = plan

  variables {
    check_approvals = [
      {
        key                  = "bad-type"
        target_resource_type = "invalid"
        approvers            = ["00000000-0000-0000-0000-000000000000"]
      }
    ]
  }

  expect_failures = [
    var.check_approvals,
  ]
}

run "invalid_approver_entries" {
  command = plan

  variables {
    check_approvals = [
      {
        key       = "empty-approver"
        approvers = [""]
      }
    ]
  }

  expect_failures = [
    var.check_approvals,
  ]
}

run "duplicate_kubernetes_keys" {
  command = plan

  variables {
    kubernetes_resources = [
      {
        service_endpoint_id = "00000000-0000-0000-0000-000000000000"
        name                = "dup-k8s"
        namespace           = "default"
      },
      {
        service_endpoint_id = "00000000-0000-0000-0000-000000000000"
        name                = "dup-k8s"
        namespace           = "default"
      }
    ]
  }

  expect_failures = [
    var.kubernetes_resources,
  ]
}

run "duplicate_check_keys" {
  command = plan

  variables {
    check_branch_controls = [
      {
        display_name     = "Duplicate check"
        allowed_branches = "refs/heads/main"
      },
      {
        display_name     = "Duplicate check"
        allowed_branches = "refs/heads/main"
      }
    ]
  }

  expect_failures = [
    var.check_branch_controls,
  ]
}

run "invalid_business_hours_fields" {
  command = plan

  variables {
    check_business_hours = [
      {
        display_name = "Invalid business hours"
        start_time   = ""
        end_time     = "18:00"
        time_zone    = "UTC"
        monday       = true
      }
    ]
  }

  expect_failures = [
    var.check_business_hours,
  ]
}

run "invalid_rest_api_fields" {
  command = plan

  variables {
    check_rest_apis = [
      {
        display_name                    = "Invalid REST API check"
        connected_service_name_selector = ""
        connected_service_name          = "service"
        method                          = "GET"
      }
    ]
  }

  expect_failures = [
    var.check_rest_apis,
  ]
}

run "missing_required_fields" {
  command = plan

  variables {
    kubernetes_resources = [
      {
        service_endpoint_id = ""
        name                = ""
        namespace           = ""
      }
    ]
  }

  expect_failures = [
    var.kubernetes_resources,
  ]
}

run "invalid_minimum_approvers" {
  command = plan

  variables {
    check_approvals = [
      {
        key                        = "min-approver"
        approvers                  = ["00000000-0000-0000-0000-000000000000"]
        minimum_required_approvers = 2
      }
    ]
  }

  expect_failures = [
    var.check_approvals,
  ]
}
