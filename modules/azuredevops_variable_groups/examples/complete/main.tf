provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_variable_groups" {
  source = "../../"

  project_id = var.project_id

  variable_groups = {
    app = {
      name         = "${var.group_name_prefix}-${random_string.suffix.result}"
      description  = "Application configuration"
      allow_access = true
      variables = [
        {
          name  = "environment"
          value = "staging"
        },
        {
          name  = "log_level"
          value = "info"
        }
      ]
    }
    secrets = {
      name         = "${var.secret_group_name_prefix}-${random_string.suffix.result}"
      description  = "Secrets for pipelines"
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
      principal          = var.principal_descriptor
      permissions = {
        View = "allow"
        Use  = "allow"
      }
    }
  ]

  library_permissions = [
    {
      principal = var.library_principal_descriptor
      permissions = {
        View   = "allow"
        Create = "allow"
        Use    = "allow"
      }
    }
  ]
}
