terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

module "azuredevops_variable_groups" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_variable_groups?ref=ADOVG1.0.0"

  project_id = var.project_id
  name       = "secure-vars"

  description  = "Restricted secrets"
  allow_access = false

  variables = [
    {
      name         = "token"
      secret_value = var.secret_token
      is_secret    = true
    }
  ]

  variable_group_permissions = [
    {
      key       = "secure-access"
      principal = var.principal_descriptor
      permissions = {
        View       = "allow"
        Use        = "allow"
        Administer = "deny"
      }
    }
  ]
}
