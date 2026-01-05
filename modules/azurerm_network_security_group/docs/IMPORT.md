# Import existing NSG into the module (Terraform import blocks)

This guide shows how to import an existing Network Security Group into
`modules/azurerm_network_security_group` using Terraform **import blocks**.

The flow is based on the **basic example** from the module README and keeps
only the **module block** (no extra Terraform resources in the config).

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- You already know the **NSG name**, **resource group**, and **subscription**

---

## 1) Prepare a minimal config (module block only)

Create `main.tf` and copy the **module block** from the basic example.
Replace values with your **existing** NSG settings.

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

module "network_security_group" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_network_security_group?ref=NSGv1.0.3"

  name                = var.nsg_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Optional: manage existing security rules
  # security_rules = [
  #   {
  #     name                       = "allow_ssh"
  #     priority                   = 100
  #     direction                  = "Inbound"
  #     access                     = "Allow"
  #     protocol                   = "Tcp"
  #     source_port_range          = "*"
  #     destination_port_range     = "22"
  #     source_address_prefix      = "10.0.0.0/8"
  #     destination_address_prefix = "*"
  #     description                = "Allow SSH"
  #   }
  # ]

  tags = var.tags
}
```

Create `terraform.tfvars` with **real values** from your NSG:

```hcl
nsg_name            = "nsg-prod"
resource_group_name = "rg-network-prod"
location            = "westeurope"

tags = {
  Environment = "Prod"
  ManagedBy   = "Terraform"
}
```

### Where to get values (Azure CLI)

```bash
az network nsg show -g <rg> -n <nsg> --query '{name:name,location:location}' -o table
```

---

## 2) Add the import block(s)

Create `import.tf` with the NSG import block:

```hcl
import {
  to = module.network_security_group.azurerm_network_security_group.network_security_group
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/networkSecurityGroups/<nsg_name>"
}
```

To get the **exact ID**:

```bash
az network nsg show -g <rg> -n <nsg> --query id -o tsv
```

### Optional imports (rules)

If you want the module to **manage existing rules**, you must:
1) Define them in `security_rules`, and
2) Import each rule into state:

```hcl
import {
  to = module.network_security_group.azurerm_network_security_rule.security_rules["allow_ssh"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/networkSecurityGroups/<nsg>/securityRules/allow_ssh"
}
```

To get rule IDs:

```bash
az network nsg rule show -g <rg> --nsg-name <nsg> -n <rule> --query id -o tsv
```

---

## 3) Run the import

```bash
terraform init
terraform plan
terraform apply
```

Expected output in `plan`:
- one **import** action for the NSG
- **no other changes** (unless you plan to manage rules)

---

## 4) Verify and clean up

```bash
terraform plan
terraform state list | rg network_security_group
```

If the plan is clean, you can **remove the import block** (`import.tf`).

---

## Common errors and fixes

- **Import does nothing**: import blocks run only on `terraform apply`. Run `plan` then `apply`.
- **Resource not found**: wrong ID or subscription. Use `az account show` and `az network nsg show -g <rg> -n <nsg> --query id -o tsv`.
- **Plan shows changes after import**: inputs do not match the existing NSG. Re-check:
  - rule definitions (`security_rules`)
  - tags
  - location and resource group
- **Rules not managed**: if you want rule management, define them in `security_rules` and import each rule.
