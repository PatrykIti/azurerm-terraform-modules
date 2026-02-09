# Terraform Azure Windows Virtual Machine Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages a single Azure Windows Virtual Machine with optional managed data disks,
VM extensions, and diagnostic settings. The module is designed to be atomic and
compose with network, identity, and monitoring modules in higher-level stacks.

## Usage

```hcl
module "windows_virtual_machine" {
  source = "path/to/azurerm_windows_virtual_machine"

  name                = "winvm-basic-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B2s"

  network = {
    network_interface_ids = [azurerm_network_interface.example.id]
  }

  admin = {
    username = "azureuser"
    password = random_password.admin.result
  }

  image = {
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-g2"
      version   = "latest"
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    Environment = "Development"
    Example     = "Basic"
  }
}
```

## Notes

- `data_disks` are implemented using `azurerm_managed_disk` +
  `azurerm_virtual_machine_data_disk_attachment` because the
  `azurerm_windows_virtual_machine` schema in azurerm 4.57.0 does not expose an
  inline data disk block.
- Use `network.primary_network_interface_id` to force NIC ordering when needed.
  The module places this NIC first in `network.network_interface_ids`.

## Examples

<!-- BEGIN_EXAMPLES -->
<!-- Examples list will be auto-generated here -->
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->
<!-- This file will be automatically populated by terraform-docs -->
<!-- Do not edit manually - use terraform-docs to generate -->
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing resources into the module
