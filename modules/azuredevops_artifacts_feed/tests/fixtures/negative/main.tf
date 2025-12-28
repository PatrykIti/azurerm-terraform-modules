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

module "azuredevops_artifacts_feed" {
  source = "../../../"

  feed_permissions = [
    {
      key                 = "missing-feed"
      identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
      role                = "reader"
    }
  ]
}
