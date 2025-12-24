provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

module "azuredevops_team" {
  source = "../../"

  project_id = var.project_id

  teams = {
    security = {
      name        = "${var.team_name_prefix}-${random_string.suffix.result}"
      description = "Security review team"
    }
  }

  team_administrators = [
    {
      team_key          = "security"
      admin_descriptors = [data.azuredevops_group.project_collection_admins.descriptor]
      mode              = "overwrite"
    }
  ]
}
