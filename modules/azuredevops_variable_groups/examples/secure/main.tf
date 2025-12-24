provider "azuredevops" {}

module "azuredevops_variable_groups" {
  source = "../../"

  project_id = var.project_id

  variable_groups = {
    secure = {
      name         = "secure-vars"
      description  = "Restricted secrets"
      allow_access = false
      variables = [
        {
          name         = "token"
          secret_value = var.secret_token
          is_secret    = true
        }
      ]
    }
  }

  variable_group_permissions = [
    {
      variable_group_key = "secure"
      principal          = var.principal_descriptor
      permissions = {
        View       = "allow"
        Use        = "allow"
        Administer = "deny"
      }
    }
  ]
}
