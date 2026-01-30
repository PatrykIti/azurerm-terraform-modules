# Import existing User Assigned Identity into the module (Terraform import blocks)

This guide shows how to import an existing User Assigned Identity (UAI) and its
federated identity credentials into `modules/azurerm_user_assigned_identity`
using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI authenticated (`az login`)
- Existing UAI name, resource group, and subscription

---

## 1) Minimal configuration

Create a minimal `main.tf` with the module only:

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

module "user_assigned_identity" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_user_assigned_identity?ref=UAIv1.0.0"

  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}
```

---

## 2) Add import blocks

### Import the User Assigned Identity

Create `import.tf` with the import block:

```hcl
import {
  to = module.user_assigned_identity.azurerm_user_assigned_identity.main
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<name>"
}
```

Get the ID with Azure CLI:

```bash
az identity show -g <rg> -n <name> --query id -o tsv
```

### Import a federated identity credential (optional)

Add an import block per credential:

```hcl
import {
  to = module.user_assigned_identity.azurerm_federated_identity_credential.main["<credential-name>"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<name>/federatedIdentityCredentials/<credential-name>"
}
```

If available, use Azure CLI to get the credential ID:

```bash
az identity federated-credential show \
  --identity-name <name> \
  --resource-group <rg> \
  --name <credential-name> \
  --query id -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

After a clean plan, you can remove the import block(s).
