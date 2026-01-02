# Import existing Azure DevOps Environment into the module

This guide explains how to import an existing Azure DevOps environment into
`modules/azuredevops_environments` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks)
- Azure DevOps provider **1.12.2**
- Access to the Azure DevOps organization and a valid PAT

---

## 1) Minimal module configuration

Create `main.tf` with a minimal module block and fill it with the **current**
environment settings.

```hcl
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

module "azuredevops_environments" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_environments?ref=ADOEv1.0.0"

  project_id  = "00000000-0000-0000-0000-000000000000"
  name        = "ado-env-import-example"
  description = "Existing environment managed by Terraform"
}
```

---

## 2) Add the import block

Create `import.tf`:

```hcl
import {
  to = module.azuredevops_environments.azuredevops_environment.environment
  id = "environment-id"
}
```

> Note: Some provider versions expect a composite ID format.
> If `terraform import` fails, try `"<project_id>/<environment_id>"` and
> confirm the exact format in the Azure DevOps provider docs.

---

## 3) (Optional) Import Kubernetes resources and checks

When importing child resources, use the same names you configured in
`kubernetes_resources` and the `check_*` lists. Environment checks are keyed
as `environment:<check_name>`. Kubernetes checks are keyed as
`kubernetes:<resource_name>:<check_name>`.

```hcl
import {
  to = module.azuredevops_environments.azuredevops_environment_resource_kubernetes.environment_resource_kubernetes["ado-env-import-k8s"]
  id = "<project_id>/<environment_id>/<kubernetes_resource_id>"
}

import {
  to = module.azuredevops_environments.azuredevops_check_approval.check_approval["environment:prod-approval"]
  id = "<project_id>/<check_id>"
}

import {
  to = module.azuredevops_environments.azuredevops_check_branch_control.check_branch_control["kubernetes:ado-env-import-k8s:k8s-branch-gate"]
  id = "<project_id>/<check_id>"
}
```

> Note: Check resources use provider-specific composite IDs. Refer to the
> Azure DevOps provider docs for the exact import format.

---

## 4) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output:
- one **import** action for `azuredevops_environment`
- no other changes

---

## 5) Verify and clean up

```bash
terraform plan
terraform state list | rg azuredevops_environment
```

When the plan is clean, you can remove `import.tf`.

---

## Additional resources

- Check resources (Kubernetes resources and approvals) can be imported separately
  if you want Terraform to own them; use the provider docs for the required IDs.
