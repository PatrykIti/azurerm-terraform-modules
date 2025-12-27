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

# This should fail due to conflicting team selectors
module "azuredevops_team" {
  source = "../../../"

  project_id = "00000000-0000-0000-0000-000000000000"

  teams = {
    bad = {
      name = "ado-team-negative"
    }
  }

  team_members = [
    {
      team_id            = "00000000-0000-0000-0000-000000000000"
      team_key           = "bad"
      member_descriptors = ["vssgp.invalid"]
    }
  ]
}
