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

# This should fail due to missing key when team_id is omitted
module "azuredevops_team" {
  source = "../../../"

  project_id  = var.project_id
  name        = "ado-team-neg-${var.random_suffix}"
  description = "Negative fixture"

  team_members = [
    {
      member_descriptors = ["vssgp.invalid"]
    }
  ]
}
