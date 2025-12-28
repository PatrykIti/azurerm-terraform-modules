provider "azuredevops" {}

module "azuredevops_servicehooks" {
  source = "../../"

  project_id = var.project_id

  webhook = {
    url      = var.webhook_url
    git_push = {}
  }
}
