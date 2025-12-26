provider "azuredevops" {}

module "azuredevops_extension" {
  source = "../../"

  publisher_id = var.publisher_id
  extension_id = var.extension_id
  version      = var.version
}
