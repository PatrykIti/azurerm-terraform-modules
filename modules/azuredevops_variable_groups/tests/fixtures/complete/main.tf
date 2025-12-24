provider "azuredevops" {}

data "azuredevops_group" "readers" {
  project_id = var.project_id
  name       = "Readers"
}

module "azuredevops_variable_groups" {
  source = "../../"

  project_id = var.project_id

  variable_groups = {
    app = {
      name         = "${var.group_name_prefix}-app"
      description  = "Application variables"
      allow_access = true
      variables = [
        {
          name  = "environment"
          value = "staging"
        },
        {
          name  = "region"
          value = "westeurope"
        }
      ]
    }
    secrets = {
      name         = "${var.group_name_prefix}-secrets"
      description  = "Secrets"
      allow_access = false
      variables = [
        {
          name         = "api_key"
          secret_value = "example-secret"
          is_secret    = true
        }
      ]
    }
  }

  variable_group_permissions = [
    {
      variable_group_key = "app"
      principal          = data.azuredevops_group.readers.id
      permissions = {
        View = "allow"
        Use  = "allow"
      }
    }
  ]

  library_permissions = [
    {
      principal = data.azuredevops_group.readers.id
      permissions = {
        View   = "allow"
        Create = "allow"
        Use    = "allow"
      }
    }
  ]
}
