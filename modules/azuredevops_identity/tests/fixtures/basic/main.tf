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

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_identity" {
  source = "../../../"

  groups = {
    readers = {
      display_name = "${var.group_name_prefix}-${random_string.suffix.result}"
      description  = "Test readers group"
    }
  }
}
