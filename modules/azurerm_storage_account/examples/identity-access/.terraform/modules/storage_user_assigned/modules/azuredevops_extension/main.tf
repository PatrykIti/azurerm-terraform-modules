# Azure DevOps Extension

resource "azuredevops_extension" "extension" {
  publisher_id = var.publisher_id
  extension_id = var.extension_id
  version      = var.extension_version
}
