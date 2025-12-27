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
  source = "../../../"

  project_id = var.project_id
  name       = "${var.group_name_prefix}-network"

  description  = "Network validation group"
  allow_access = true

  variables = [
    {
      name  = "network"
      value = "enabled"
    }
  ]
}
