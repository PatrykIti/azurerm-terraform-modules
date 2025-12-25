provider "azuredevops" {}

module "azuredevops_servicehooks" {
  source = "../../"

  project_id = var.project_id

  webhooks = [
    {
      url = var.webhook_url
      work_item_updated = {
        work_item_type = "Bug"
        area_path      = var.area_path
        changed_fields = "System.State"
      }
    }
  ]

  servicehook_permissions = [
    {
      principal = var.principal_descriptor
      permissions = {
        ViewSubscriptions   = "allow"
        EditSubscriptions   = "deny"
        DeleteSubscriptions = "deny"
        PublishEvents       = "deny"
      }
    }
  ]
}
