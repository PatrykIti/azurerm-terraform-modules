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

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

resource "azuredevops_serviceendpoint_kubernetes" "example" {
  project_id            = var.project_id
  service_endpoint_name = "ado-env-complete-example-k8s"
  apiserver_url         = var.kubernetes_api_url
  authorization_type    = "Kubeconfig"

  kubeconfig {
    kube_config            = <<EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority: fake-ca-file
    server: https://1.2.3.4
  name: development
contexts:
- context:
    cluster: development
    namespace: default
    user: developer
  name: dev-default
current-context: dev-default
kind: Config
preferences: {}
users:
- name: developer
  user:
    client-certificate: fake-cert-file
    client-key: fake-key-file
EOT
    accept_untrusted_certs = true
    cluster_context        = "dev-default"
  }
}

module "azuredevops_environments" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_environments?ref=ADOEv1.0.0"

  project_id  = var.project_id
  name        = "ado-env-complete-example"
  description = "Production environment"

  kubernetes_resources = [
    {
      name                = "ado-env-complete-example-k8s"
      namespace           = "default"
      service_endpoint_id = azuredevops_serviceendpoint_kubernetes.example.id
      cluster_name        = "example-aks"
      checks = {
        branch_controls = [
          {
            name                     = "Require protected branches"
            allowed_branches         = "refs/heads/main"
            verify_branch_protection = true
          }
        ]
      }
    }
  ]

  check_approvals = [
    {
      name                  = "primary-approval"
      approvers             = [data.azuredevops_group.project_collection_admins.origin_id]
      requester_can_approve = false
    }
  ]
}
