# Import existing Azure DevOps generic service endpoints

This guide shows how to import an existing generic service endpoint into
`modules/azuredevops_serviceendpoint` using Terraform import blocks.

## 1) Minimal module configuration

```hcl
module "azuredevops_serviceendpoint" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_serviceendpoint?ref=ADOSEv1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"

  serviceendpoint_generic = {
    service_endpoint_name = "existing-endpoint"
    server_url            = "https://example.endpoint.local"
  }
}
```

## 2) Import endpoint resource

```hcl
import {
  to = module.azuredevops_serviceendpoint.azuredevops_serviceendpoint_generic.generic
  id = "<service-endpoint-id>"
}
```

## 3) Optional permissions import

When importing permissions, use the same keys as `coalesce(key, principal)`.

```hcl
import {
  to = module.azuredevops_serviceendpoint.azuredevops_serviceendpoint_permissions.permissions["project-admins"]
  id = "<serviceendpoint_permissions_id>"
}
```

## 4) Run import

```bash
terraform init
terraform plan
terraform apply
```
