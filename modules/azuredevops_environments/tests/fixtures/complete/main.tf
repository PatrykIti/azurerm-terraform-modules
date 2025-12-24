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

resource "azuredevops_serviceendpoint_kubernetes" "example" {
  project_id            = var.project_id
  service_endpoint_name = "${var.environment_name_prefix}-k8s-${random_string.suffix.result}"
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
  source = "../.."

  project_id = var.project_id

  environments = {
    complete = {
      name        = "${var.environment_name_prefix}-${random_string.suffix.result}"
      description = "Complete environment"
    }
  }

  kubernetes_resources = [
    {
      environment_key     = "complete"
      service_endpoint_id = azuredevops_serviceendpoint_kubernetes.example.id
      name                = "${var.environment_name_prefix}-k8s-${random_string.suffix.result}"
      namespace           = "default"
      cluster_name        = "example-aks"
    }
  ]

  check_approvals = [
    {
      target_environment_key = "complete"
      target_resource_type   = "environment"
      approvers              = [data.azuredevops_group.project_collection_admins.id]
      requester_can_approve  = false
    }
  ]
}
