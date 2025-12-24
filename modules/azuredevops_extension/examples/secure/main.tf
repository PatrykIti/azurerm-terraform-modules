provider "azuredevops" {}

module "azuredevops_extension" {
  source = "../../"

  extensions = var.approved_extensions
}
