# Azure DevOps Extensions

locals {
  extensions_by_key = {
    for extension in var.extensions :
    "${extension.publisher_id}/${extension.extension_id}" => extension
  }
}

resource "azuredevops_extension" "extension" {
  for_each = local.extensions_by_key

  publisher_id = each.value.publisher_id
  extension_id = each.value.extension_id
  version      = each.value.version
}
