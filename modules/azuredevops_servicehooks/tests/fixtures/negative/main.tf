provider "azuredevops" {}

module "azuredevops_servicehooks" {
  source = "../../"

  project_id = var.project_id

  webhooks = [
    {
      url = var.webhook_url
    }
  ]
}
