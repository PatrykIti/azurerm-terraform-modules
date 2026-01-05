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

module "azuredevops_environments" {
  source = "../../../"

  project_id = var.project_id
  name       = var.environment_name

  check_approvals = [
    {
      name      = ""
      approvers = ["00000000-0000-0000-0000-000000000000"]
    }
  ]
}
