provider "azuredevops" {}

module "azuredevops_serviceendpoint" {
  source = "../../"

  project_id = var.project_id

  serviceendpoint_azurerm = [
    {
      key                       = "azurerm-basic"
      service_endpoint_name     = var.azurerm_endpoint_name
      azurerm_spn_tenantid      = var.azurerm_spn_tenantid
      serviceprincipalid        = var.azurerm_spn_client_id
      serviceprincipalkey       = var.azurerm_spn_client_secret
      azurerm_subscription_id   = var.azurerm_subscription_id
      azurerm_subscription_name = var.azurerm_subscription_name
      description               = "Managed by Terraform"
    }
  ]

  serviceendpoint_dockerregistry = [
    {
      key                   = "docker-basic"
      service_endpoint_name = var.docker_endpoint_name
      docker_registry       = var.docker_registry
      docker_username       = var.docker_username
      docker_email          = var.docker_email
      docker_password       = var.docker_password
      registry_type         = var.docker_registry_type
      description           = "Managed by Terraform"
    }
  ]
}
