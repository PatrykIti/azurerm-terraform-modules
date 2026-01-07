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
      key         = "basic-reader"
      scope       = "project"
      resource_id = var.resource_id
      role_name   = "Reader"
      identity_id = var.identity_id
    }
  ]
}
