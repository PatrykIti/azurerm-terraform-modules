# Import Azure DevOps Environment Resources

This guide shows how to import existing resources into `modules/azuredevops_environments`.

## Requirements

- Terraform `>= 1.5` (import blocks)
- Azure DevOps provider `1.12.2`

## 1) Minimal module configuration

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

  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "ado-env-import-example"
}
```

## 2) Import environment

```hcl
import {
  to = module.azuredevops_environments.azuredevops_environment.environment
  id = "<environment_id>"
}
```

If your provider/API expects a composite ID, use the format from provider docs.

## 3) Optional imports

### Kubernetes resource in environment

```hcl
import {
  to = module.azuredevops_environments.azuredevops_environment_resource_kubernetes.environment_resource_kubernetes["ado-env-k8s"]
  id = "<project_id>/<environment_id>/<kubernetes_resource_id>"
}
```

### Environment-level approval check

```hcl
import {
  to = module.azuredevops_environments.azuredevops_check_approval.check_approval_environment["prod-approval"]
  id = "<project_id>/<check_id>"
}
```

### Kubernetes nested approval check

Nested check keys are `<kubernetes_resource_name>:<check_name>`.

```hcl
import {
  to = module.azuredevops_environments.azuredevops_check_approval.check_approval_kubernetes["ado-env-k8s:prod-approval"]
  id = "<project_id>/<check_id>"
}
```

## 4) Run import

```bash
terraform init
terraform plan
terraform apply
```

## 5) Verify

```bash
terraform plan
terraform state list | rg azuredevops_environment
```

Remove import blocks after successful import.
