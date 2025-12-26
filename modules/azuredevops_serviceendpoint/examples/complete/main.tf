provider "azuredevops" {}

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

module "azuredevops_serviceendpoint" {
  source = "../../"

  project_id = var.project_id

  serviceendpoint_github = [
    {
      key                   = "github-complete"
      service_endpoint_name = var.github_endpoint_name
      auth_personal = {
        personal_access_token = var.github_personal_access_token
      }
      description = "Managed by Terraform"
    }
  ]

  serviceendpoint_aws = [
    {
      key                   = "aws-complete"
      service_endpoint_name = var.aws_endpoint_name
      access_key_id         = var.aws_access_key_id
      secret_access_key     = var.aws_secret_access_key
      description           = "Managed by Terraform"
    }
  ]

  serviceendpoint_kubernetes = [
    {
      key                   = "kubernetes-complete"
      service_endpoint_name = var.kubernetes_endpoint_name
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
      serviceendpoint_type = "github"
      serviceendpoint_key  = "github-complete"
    }
  ]
}
