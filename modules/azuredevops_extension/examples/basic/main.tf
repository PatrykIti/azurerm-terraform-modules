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

module "azuredevops_extension" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_extension?ref=ADOEX1.0.0"

  publisher_id      = var.publisher_id
  extension_id      = var.extension_id
  extension_version = var.extension_version
}
