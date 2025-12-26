provider "azuredevops" {}

module "azuredevops_serviceendpoint" {
  source = "../.."

  project_id = var.project_id

  serviceendpoint_generic = [
    {
      key                   = "generic-basic"
      service_endpoint_name = "${var.generic_endpoint_name_prefix}"
      server_url            = var.generic_endpoint_url
      username              = var.generic_endpoint_username
      password              = var.generic_endpoint_password
      description           = "Managed by Terraform"
    }
  ]
}
