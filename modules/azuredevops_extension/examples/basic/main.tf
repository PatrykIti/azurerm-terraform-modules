provider "azuredevops" {}

module "azuredevops_extension" {
  source = "../../"

  extensions = [
    {
      publisher_id = var.publisher_id
      extension_id = var.extension_id
      version      = var.extension_version
    }
  ]
}
