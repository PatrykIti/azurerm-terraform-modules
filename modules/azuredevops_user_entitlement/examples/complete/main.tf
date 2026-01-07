terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

module "azuredevops_user_entitlement" {
  source = "../../"

  user_entitlements = [
    {
      key                  = "platform-user"
      principal_name       = var.platform_user_principal_name
      account_license_type = "basic"
      licensing_source     = "account"
    },
    {
      key                  = "automation-user"
      principal_name       = var.automation_user_principal_name
      account_license_type = "stakeholder"
      licensing_source     = "account"
    }
  ]
}
