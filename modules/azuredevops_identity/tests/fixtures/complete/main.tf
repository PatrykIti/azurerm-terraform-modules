provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_identity" {
  source = "../../"

  groups = {
    platform = {
      display_name = "${var.group_name_prefix}-platform-${random_string.suffix.result}"
      description  = "Platform engineering group"
    }
    developers = {
      display_name = "${var.group_name_prefix}-developers-${random_string.suffix.result}"
      description  = "Development contributors"
    }
  }

  group_memberships = [
    {
      group_key         = "platform"
      member_group_keys = ["developers"]
      mode              = "add"
    }
  ]
}
