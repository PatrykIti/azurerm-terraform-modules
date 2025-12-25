provider "azuredevops" {}

module "azuredevops_servicehooks" {
  source = "../../"

  project_id = var.project_id

  webhooks = [
    {
      url = var.webhook_url
      build_completed = {
        build_status = "Succeeded"
      }
      http_headers = {
        "X-Test" = "true"
      }
    }
  ]
}
