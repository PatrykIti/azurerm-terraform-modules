# Import existing Role Definition into the module

This guide shows how to import an existing custom Role Definition into
`modules/azurerm_role_definition` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- You know the **scope** and the **role definition ID**

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` with a module block that matches the existing role:

```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "role_definition" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_role_definition?ref=RDv1.0.0"

  name  = var.role_definition_name
  scope = var.scope

  permissions = var.permissions
  assignable_scopes = var.assignable_scopes
}
```

Create `terraform.tfvars` with real values:

```hcl
role_definition_name = "Custom Role"
scope                = "/subscriptions/<sub>"

permissions = [
  {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/read"
    ]
  }
]

assignable_scopes = [
  "/subscriptions/<sub>"
]
```

---

## 2) Add the import block

Create `import.tf` with the role definition ID:

```hcl
import {
  to = module.role_definition.azurerm_role_definition.role_definition
  id = "/subscriptions/<sub>/providers/Microsoft.Authorization/roleDefinitions/<role-definition-guid>"
}
```

For management group scope, the ID format is:

```
/providers/Microsoft.Management/managementGroups/<mg-id>/providers/Microsoft.Authorization/roleDefinitions/<role-definition-guid>
```

To list custom role definitions:

```bash
az role definition list --custom-role-only true --query "[0].id" -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

After `apply`, Terraform should show the role definition as **imported** with no changes.

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg role_definition
```

If the plan is clean, you can remove `import.tf`.
