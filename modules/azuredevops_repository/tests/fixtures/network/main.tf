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

module "azuredevops_repository" {
  source = "../../../"

  project_id = var.project_id
  name       = "${var.repo_name_prefix}-network"

  initialization = {
    init_type = "Clean"
  }
}
