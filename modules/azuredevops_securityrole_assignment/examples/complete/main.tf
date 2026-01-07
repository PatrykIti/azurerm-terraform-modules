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

module "azuredevops_securityrole_assignment" {
  source = "../../"

  securityrole_assignments = [
    {
      key         = "project-reader"
      scope       = "project"
      resource_id = var.project_id
      role_name   = "Reader"
      identity_id = var.reader_identity_id
    },
    {
      key         = "project-contributor"
      scope       = "project"
      resource_id = var.project_id
      role_name   = "Contributor"
      identity_id = var.contributor_identity_id
    }
  ]
}
