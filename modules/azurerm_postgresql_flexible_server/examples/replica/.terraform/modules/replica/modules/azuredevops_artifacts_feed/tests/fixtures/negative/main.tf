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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

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
