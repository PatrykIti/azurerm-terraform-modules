provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_environments" {
  source = "../.."

  project_id = var.project_id

  environments = {
    basic = {
      name        = "${var.environment_name_prefix}-${random_string.suffix.result}"
      description = "Basic environment"
    }
  }
}
