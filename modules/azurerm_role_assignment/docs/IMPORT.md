# Import existing Role Assignment into the module

This guide shows how to import an existing Role Assignment into
`modules/azurerm_role_assignment` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- You know the **scope**, **principal_id**, and the **role assignment ID**

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` with a module block that matches the existing assignment:

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

module "role_assignment" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_role_assignment?ref=RAv1.0.0"

  scope                = var.scope
  principal_id         = var.principal_id
  role_definition_name = var.role_definition_name
}
```

Create `terraform.tfvars` with real values:

```hcl
scope                = "/subscriptions/<sub>/resourceGroups/<rg>"
principal_id         = "00000000-0000-0000-0000-000000000000"
role_definition_name = "Reader"
```

---

## 2) Add the import block

Create `import.tf` with the role assignment ID:

```hcl
import {
  to = module.role_assignment.azurerm_role_assignment.role_assignment
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Authorization/roleAssignments/<assignment-guid>"
}
```

To get the assignment ID:

```bash
az role assignment list --scope "<scope>" --assignee "<principal_id>" --query "[0].id" -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

After `apply`, Terraform should show the assignment as **imported** with no changes.

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg role_assignment
```

If the plan is clean, you can remove `import.tf`.
