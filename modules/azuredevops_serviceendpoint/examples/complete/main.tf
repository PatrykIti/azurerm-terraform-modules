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

module "azuredevops_serviceendpoint" {
  source = "../../"

  project_id = var.project_id

  serviceendpoint_github = [
    {
      service_endpoint_name = "${var.github_endpoint_name_prefix}-${random_string.suffix.result}"
      auth_personal = {
        personal_access_token = var.github_personal_access_token
      }
      description = "Managed by Terraform"
    }
  ]

  serviceendpoint_aws = [
    {
      service_endpoint_name = "${var.aws_endpoint_name_prefix}-${random_string.suffix.result}"
      access_key_id         = var.aws_access_key_id
      secret_access_key     = var.aws_secret_access_key
      description           = "Managed by Terraform"
    }
  ]

  serviceendpoint_kubernetes = [
    {
      service_endpoint_name = "${var.kubernetes_endpoint_name_prefix}-${random_string.suffix.result}"
      apiserver_url         = var.kubernetes_api_url
      authorization_type    = "Kubeconfig"
      kubeconfig = {
        kube_config            = var.kubeconfig_content
        accept_untrusted_certs = true
        cluster_context        = var.kubeconfig_context
      }
      description = "Managed by Terraform"
    }
  ]

  serviceendpoint_permissions = [
    {
      principal = data.azuredevops_group.project_collection_admins.id
      permissions = {
        Use        = "Allow"
        Administer = "Deny"
      }
    }
  ]
}
