# Negative test cases - should fail validation
provider "azuredevops" {}

module "azuredevops_repository" {
  source = "../../../"

  project_id = "00000000-0000-0000-0000-000000000000"

  branches = [
    {
      repository_id  = "00000000-0000-0000-0000-000000000000"
      repository_key = "main"
      name           = "invalid-branch"
    }
  ]
}
