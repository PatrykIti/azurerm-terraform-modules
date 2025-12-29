# Test variable validation for Azure DevOps Service Endpoints

mock_provider "azuredevops" {}

variables {
  project_id = "00000000-0000-0000-0000-000000000000"
}

run "invalid_permissions_missing_endpoint" {
  command = plan

  variables {
    serviceendpoint_permissions = [
      {
        principal = "vssgp.invalid"
        permissions = {
          Use = "Allow"
        }
      }
    ]
  }

  expect_failures = [
    var.project_id,
  ]
}

run "invalid_permissions_duplicate_key" {
  command = plan

  variables {
    serviceendpoint_generic = {
      service_endpoint_name = "generic-endpoint"
      server_url            = "https://example.endpoint.local"
    }

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
    serviceendpoint_generic = {
      service_endpoint_name = "generic-endpoint"
      server_url            = "https://example.endpoint.local"
    }

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

run "invalid_multiple_endpoints" {
  command = plan

  variables {
    serviceendpoint_generic = {
      service_endpoint_name = "generic-endpoint"
      server_url            = "https://example.endpoint.local"
    }

    serviceendpoint_gitlab = {
      service_endpoint_name = "gitlab-endpoint"
      url                   = "https://gitlab.example.local"
      username              = "user"
      api_token             = "token"
    }
  }

  expect_failures = [
    var.project_id,
  ]
}

run "invalid_github_auth" {
  command = plan

  variables {
    serviceendpoint_github = {
      service_endpoint_name = "github-endpoint"
      auth_personal = {
        personal_access_token = "token"
      }
      auth_oauth = {
        oauth_configuration_id = "oauth-id"
      }
    }
  }

  expect_failures = [
    var.serviceendpoint_github,
  ]
}

run "invalid_kubernetes_auth" {
  command = plan

  variables {
    serviceendpoint_kubernetes = {
      service_endpoint_name = "k8s-endpoint"
      apiserver_url         = "https://example.kubernetes.local"
      authorization_type    = "Kubeconfig"
    }
  }

  expect_failures = [
    var.serviceendpoint_kubernetes,
  ]
}

run "invalid_openshift_auth" {
  command = plan

  variables {
    serviceendpoint_openshift = {
      service_endpoint_name = "openshift-endpoint"
      auth_basic = {
        username = "user"
        password = "pass"
      }
      auth_token = {
        token = "token"
      }
    }
  }

  expect_failures = [
    var.serviceendpoint_openshift,
  ]
}

run "invalid_ssh_auth" {
  command = plan

  variables {
    serviceendpoint_ssh = {
      service_endpoint_name = "ssh-endpoint"
      host                  = "ssh.example.local"
      username              = "user"
      password              = "pass"
      private_key           = "key"
    }
  }

  expect_failures = [
    var.serviceendpoint_ssh,
  ]
}

run "invalid_aws_auth" {
  command = plan

  variables {
    serviceendpoint_aws = {
      service_endpoint_name = "aws-endpoint"
      access_key_id         = "access"
      secret_access_key     = "secret"
      role_to_assume        = "role"
      role_session_name     = "session"
      use_oidc              = true
    }
  }

  expect_failures = [
    var.serviceendpoint_aws,
  ]
}
