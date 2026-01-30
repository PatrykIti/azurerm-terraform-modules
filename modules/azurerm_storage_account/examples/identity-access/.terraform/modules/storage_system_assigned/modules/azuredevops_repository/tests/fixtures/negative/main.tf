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

module "azuredevops_repository" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "invalid-repo"

  branches = [
    {
      name       = "invalid-branch"
      ref_branch = "refs/heads/main"
      policies = {
        min_reviewers = {
          reviewer_count = 0
        }
      }
    }
  ]
}
