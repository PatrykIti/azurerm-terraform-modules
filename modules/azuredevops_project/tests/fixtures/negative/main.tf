# Negative test cases - should fail validation
provider "azuredevops" {}

module "azuredevops_project" {
  source = "../../../"

  project = {
    name = var.project_name
    features = {
      boards = "enabled"
    }
  }

  project_features = {
    repositories = "enabled"
  }
}
