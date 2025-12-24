provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_team" {
  source = "../../"

  project_id = var.project_id

  teams = {
    core = {
      name        = "${var.team_name_prefix}-${random_string.suffix.result}"
      description = "Test core team"
    }
  }
}
