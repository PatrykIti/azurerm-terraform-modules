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

module "azuredevops_work_items" {
  source = "../../../"

  project_id = var.project_id

  title = "${var.work_item_title_prefix}-secure"
  type  = "Task"
  state = "Active"

  tags = ["terraform", "secure"]

  custom_fields = {
    "System.Description" = "Secure fixture managed by Terraform"
  }
}
