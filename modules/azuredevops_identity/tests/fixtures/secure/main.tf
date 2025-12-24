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
    security = {
      display_name = "${var.group_name_prefix}-security-${random_string.suffix.result}"
      description  = "Security reviewers"
    }
    operators = {
      display_name = "${var.group_name_prefix}-operators-${random_string.suffix.result}"
      description  = "Operations access"
    }
  }

  group_memberships = [
    {
      group_key         = "security"
      member_group_keys = ["operators"]
      mode              = "overwrite"
    }
  ]
}
