# Import existing Azure DevOps service endpoints (Terraform import blocks)

This guide shows how to import existing Azure DevOps service endpoints into
`modules/azuredevops_serviceendpoint` using Terraform import blocks.

The examples below use the **generic** service endpoint, but the same pattern
applies to other endpoint types (`serviceendpoint_*`).

---

## Requirements

- Terraform >= 1.5 (import blocks)
- Azure DevOps provider configured with access to the target project
- The **project ID** and **service endpoint ID** you want to import

---

## 1) Minimal module configuration

Create `main.tf` with the module block and a single endpoint definition.

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

module "azuredevops_serviceendpoint" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_serviceendpoint?ref=ADOSEv1.0.0"

  project_id = var.project_id

  serviceendpoint_generic = {
    service_endpoint_name = var.service_endpoint_name
    server_url            = var.server_url
    username              = var.username
    password              = var.password
  }
}
```

---

## 2) Add an import block

Create `import.tf` with the import block that matches the endpoint resource address:

```hcl
import {
  to = module.azuredevops_serviceendpoint.azuredevops_serviceendpoint_generic.generic[0]
  id = "<service-endpoint-id>"
}
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

If the plan shows drift after import, adjust your module inputs to match the
existing endpoint configuration.

---

## Notes

- The module manages a single service endpoint per instance, so the resource address uses index `[0]`.
- Permissions can be imported with keys matching `coalesce(key, principal)`.
