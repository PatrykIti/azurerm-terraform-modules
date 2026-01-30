# Import existing Windows Virtual Machine into the module (Terraform import blocks)

This guide shows how to import an existing Windows VM into
`modules/azurerm_windows_virtual_machine` using Terraform **import blocks**.

---

## Requirements

- Terraform **>= 1.5** (import blocks) and module requirement **>= 1.12.2**
- Azure CLI logged in (`az login`)
- VM name, resource group, and subscription ID

---

## 1) Prepare a minimal config

Create `main.tf` with only the module block. Populate values to match your VM.
`admin_password` is write-only in Azure; set it to the value you want enforced.

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

module "windows_virtual_machine" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_windows_virtual_machine?ref=WINDOWSVMv1.0.0"

  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size

  network_interface_ids = var.network_interface_ids

  admin_username = var.admin_username
  admin_password = var.admin_password

  source_image_id = var.source_image_id

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
```

Create `terraform.tfvars` with real values.

---

## 2) Add import block(s)

Import the VM:

```hcl
import {
  to = module.windows_virtual_machine.azurerm_windows_virtual_machine.windows_virtual_machine
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachines/<vm>"
}
```

To get the exact ID:

```bash
az vm show -g <rg> -n <vm> --query id -o tsv
```

### Optional imports

If you enable these inputs, import their resources as well.

**Extensions**
```hcl
import {
  to = module.windows_virtual_machine.azurerm_virtual_machine_extension.virtual_machine_extensions["custom-script"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachines/<vm>/extensions/custom-script"
}
```

**Diagnostic settings**
```hcl
import {
  to = module.windows_virtual_machine.azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings["diag"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachines/<vm>/providers/microsoft.insights/diagnosticSettings/diag"
}
```

**Managed data disks (if `data_disks` is configured)**
```hcl
import {
  to = module.windows_virtual_machine.azurerm_managed_disk.data_disks["data-disk-01"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/disks/data-disk-01"
}

import {
  to = module.windows_virtual_machine.azurerm_virtual_machine_data_disk_attachment.data_disks["data-disk-01"]
  id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachines/<vm>/dataDisks/data-disk-01"
}
```

---

## 3) Apply

Run:

```bash
terraform init
terraform plan
terraform apply
```

> Import blocks run during `terraform apply`. Ensure the module inputs match the
> existing VM configuration to avoid drift.
