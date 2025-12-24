provider "azuredevops" {}

module "azuredevops_serviceendpoint" {
  source = "../.."

  project_id = var.project_id

  serviceendpoint_generic = [
    {
      service_endpoint_name = "${var.generic_endpoint_name_prefix}"
      server_url            = var.generic_endpoint_url
      username              = var.generic_endpoint_username
      password              = var.generic_endpoint_password
      description           = "Managed by Terraform"
    }
  ]

  serviceendpoint_incomingwebhook = [
    {
      service_endpoint_name = "${var.incoming_webhook_name_prefix}"
      webhook_name          = "example_webhook"
      secret                = var.incoming_webhook_secret
      http_header           = "X-Hub-Signature"
      description           = "Managed by Terraform"
    }
  ]
}
