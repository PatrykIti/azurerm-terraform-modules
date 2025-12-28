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
  service_endpoint_name = "${var.environment_name}-k8s"
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
  source = "../../../"

  project_id  = var.project_id
  name        = var.environment_name
  description = "Complete fixture environment"

  kubernetes_resources = [
    {
      name                = "${var.environment_name}-k8s"
      namespace           = "default"
      service_endpoint_id = azuredevops_serviceendpoint_kubernetes.example.id
      cluster_name        = "example-aks"
    }
  ]

  check_approvals = [
    {
      key                   = "integration-approval"
      target_resource_type  = "environment"
      approvers             = [data.azuredevops_group.project_collection_admins.origin_id]
      requester_can_approve = false
    }
  ]
}
