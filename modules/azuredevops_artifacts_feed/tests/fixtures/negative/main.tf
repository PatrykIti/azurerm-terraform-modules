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

  name       = "${var.feed_name_prefix}-invalid"
  project_id = var.project_id

  feed_permissions = [
    {
      key                 = "invalid-role"
      identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
      role                = "owner"
    }
  ]
}
