provider "azuredevops" {}

data "azuredevops_group" "readers" {
  project_id = var.project_id
  name       = "Readers"
}

module "azuredevops_variable_groups" {
  source = "../../"

  project_id = var.project_id

  variable_groups = {
    secure = {
      name         = "${var.group_name_prefix}-secure"
      description  = "Restricted secrets"
      allow_access = false
      variables = [
        {
          name         = "token"
          secret_value = "example-secret"
          is_secret    = true
        }
      ]
    }
  }

  variable_group_permissions = [
    {
      variable_group_key = "secure"
      principal          = data.azuredevops_group.readers.id
      permissions = {
        View       = "allow"
        Use        = "allow"
        Administer = "deny"
      }
    }
  ]
}
