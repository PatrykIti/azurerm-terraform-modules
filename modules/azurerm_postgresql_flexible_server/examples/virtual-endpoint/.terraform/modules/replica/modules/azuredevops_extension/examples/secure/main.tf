terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

locals {
  approved_extensions_by_key = {
    for extension in var.approved_extensions :
    "${extension.publisher_id}/${extension.extension_id}" => extension
  }
}

module "azuredevops_extension" {
  source   = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_extension?ref=ADOEXv1.0.0"
  for_each = local.approved_extensions_by_key

  publisher_id      = each.value.publisher_id
  extension_id      = each.value.extension_id
  extension_version = try(each.value.version, null)
}
