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
        display_name = "Duplicate check"
        allowed_branches = "refs/heads/main"
      },
      {
        display_name = "Duplicate check"
        allowed_branches = "refs/heads/main"
      }
    ]
  }

  expect_failures = [
    var.check_branch_controls,
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
