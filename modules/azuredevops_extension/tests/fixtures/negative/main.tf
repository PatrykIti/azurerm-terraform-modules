# Negative test cases - should fail validation
provider "azuredevops" {}

module "azuredevops_extension" {
  source = "../../../"

  publisher_id = ""
  extension_id = "invalid-extension"
}
