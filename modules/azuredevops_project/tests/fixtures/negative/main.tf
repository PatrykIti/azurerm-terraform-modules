# Negative test cases - should fail validation
provider "azuredevops" {}

module "azuredevops_project" {
  source = "../../../"

  name        = var.project_name
  description = "Negative test for validation"

  features = {
    boards = "maybe"
  }
}
