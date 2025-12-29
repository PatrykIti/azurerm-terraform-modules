# Negative test cases - should fail validation
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

module "azuredevops_project" {
  source = "../../../"

  name        = var.project_name
  description = "Negative test for validation"

  features = {
    boards = "maybe"
  }
}
