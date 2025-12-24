# Negative test cases - should fail validation
provider "azuredevops" {}

module "azuredevops_extension" {
  source = "../../../"

  extensions = [
    {
      publisher_id = ""
      extension_id = "invalid-extension"
    }
  ]
}
