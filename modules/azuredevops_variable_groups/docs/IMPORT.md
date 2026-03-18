# Import existing Azure DevOps variable groups

This guide shows how to import an existing variable group into
`modules/azuredevops_variable_groups` using Terraform import blocks.

## 1) Minimal module configuration

```hcl
module "azuredevops_variable_groups" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_variable_groups?ref=ADOVGv1.0.0"

  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "existing-variable-group"

  variables = [
    {
      name  = "environment"
      value = "prod"
    }
  ]
}
```

## 2) Import variable group resource

```hcl
import {
  to = module.azuredevops_variable_groups.azuredevops_variable_group.variable_group
  id = "<variable_group_id>"
}
```

## 3) Optional variable-group permissions import

Permissions are keyed by `coalesce(key, principal)` and always target the
module-managed variable group.

```hcl
import {
  to = module.azuredevops_variable_groups.azuredevops_variable_group_permissions.variable_group_permissions["readers"]
  id = "<variable_group_permissions_id>"
}
```

## 4) Run import

```bash
terraform init
terraform plan
terraform apply
```
