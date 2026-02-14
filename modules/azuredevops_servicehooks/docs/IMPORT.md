# Import existing Azure DevOps webhook service hooks

This guide shows how to import an existing webhook service hook into
`modules/azuredevops_servicehooks` using Terraform import blocks.

## 1) Minimal module configuration

```hcl
module "azuredevops_servicehooks" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_servicehooks?ref=ADOSHv1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"

  webhook = {
    url      = "https://example.com/webhook"
    git_push = {}
  }
}
```

## 2) Import webhook resource

```hcl
import {
  to = module.azuredevops_servicehooks.azuredevops_servicehook_webhook_tfs.webhook
  id = "<service_hook_id>"
}
```

## 3) Run import

```bash
terraform init
terraform plan
terraform apply
```
