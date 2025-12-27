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
  source = "../../../"

  publisher_id      = var.publisher_id
  extension_id      = var.extension_id
  extension_version = var.extension_version
}
