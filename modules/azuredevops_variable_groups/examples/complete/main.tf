provider "azuredevops" {}

module "azuredevops_variable_groups" {
  source = "../../"

  project_id = var.project_id
  name       = "app-vars"

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

  key_vault = {
    name                = "shared-kv"
    service_endpoint_id = var.key_vault_service_endpoint_id
    search_depth        = 1
  }

  variable_group_permissions = [
    {
      key       = "pipeline-access"
      principal = var.principal_descriptor
      permissions = {
        View = "allow"
        Use  = "allow"
      }
    }
  ]

  library_permissions = [
    {
      key       = "library-access"
      principal = var.library_principal_descriptor
      permissions = {
        View   = "allow"
        Create = "allow"
        Use    = "allow"
      }
    }
  ]
}
