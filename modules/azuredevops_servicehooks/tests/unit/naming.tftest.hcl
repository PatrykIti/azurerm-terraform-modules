# Test permission key mapping

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "permissions_explicit_key_plan" {
  command = plan

  variables {
    servicehook_permissions = [
      {
        key       = "perm-main"
        principal = "descriptor"
        permissions = {
          ViewSubscriptions = "Allow"
        }
      }
    ]
  }

  assert {
    condition     = contains(keys(azuredevops_servicehook_permissions.servicehook_permissions), "perm-main")
    error_message = "servicehook_permissions should be keyed by the provided key."
  }
}

run "permissions_default_key_plan" {
  command = plan

  variables {
    servicehook_permissions = [
      {
        principal = "descriptor"
        permissions = {
          ViewSubscriptions = "Allow"
        }
      }
    ]
  }

  assert {
    condition     = contains(keys(azuredevops_servicehook_permissions.servicehook_permissions), "descriptor")
    error_message = "servicehook_permissions should default to using principal as the key."
  }
}
