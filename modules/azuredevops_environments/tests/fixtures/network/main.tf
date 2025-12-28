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

  project_id  = var.project_id
  name        = var.environment_name
  description = "Network fixture environment"
}
