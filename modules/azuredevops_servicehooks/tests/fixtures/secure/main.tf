provider "azuredevops" {}

data "azuredevops_group" "readers" {
  project_id = var.project_id
  name       = "Readers"
}

module "azuredevops_servicehooks" {
  source = "../../"

  project_id = var.project_id

  webhooks = [
    {
      key = "secure-work-item"
      url = var.webhook_url
      work_item_updated = {
        work_item_type = "Bug"
      }
    }
  ]

  servicehook_permissions = [
    {
      key       = "readers-permissions"
      principal = data.azuredevops_group.readers.id
      permissions = {
        ViewSubscriptions   = "Allow"
        EditSubscriptions   = "Deny"
        DeleteSubscriptions = "Deny"
        PublishEvents       = "Deny"
      }
    }
  ]
}
