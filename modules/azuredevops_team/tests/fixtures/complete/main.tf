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

data "azuredevops_group" "project_collection_valid_users" {
  name = "Project Collection Valid Users"
}

module "azuredevops_team" {
  source = "../../"

  project_id = var.project_id

  teams = {
    platform = {
      name        = "${var.team_name_prefix}-platform-${random_string.suffix.result}"
      description = "Platform engineering team"
    }
    product = {
      name        = "${var.team_name_prefix}-product-${random_string.suffix.result}"
      description = "Product delivery team"
    }
  }

  team_members = [
    {
      team_key           = "platform"
      member_descriptors = [data.azuredevops_group.project_collection_valid_users.descriptor]
      mode               = "add"
    }
  ]

  team_administrators = [
    {
      team_key          = "platform"
      admin_descriptors = [data.azuredevops_group.project_collection_admins.descriptor]
      mode              = "add"
    }
  ]
}
