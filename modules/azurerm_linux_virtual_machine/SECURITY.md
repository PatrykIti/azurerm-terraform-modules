# azurerm_linux_virtual_machine Module Security

## Overview

This document outlines security-relevant configuration for the Linux Virtual Machine module.
The module manages a Linux VM and VM-scoped resources (extensions and diagnostic settings).
Networking (VNet/subnet/NSG/public IP), RBAC, Key Vault, and backup are **out of scope** and must be handled externally.

## Security Features in This Module

### Authentication
- **admin.disable_password_authentication** defaults to `true` (SSH keys only).
- **admin.ssh_keys** supports multiple SSH public keys.
- **admin.password** is supported when password auth is required.

### VM Security Profile
- **security_profile.secure_boot_enabled** and **security_profile.vtpm_enabled** enable Trusted Launch capabilities.
- **security_profile.encryption_at_host_enabled** enables host-based encryption where supported.

### Managed Identity
- **identity** supports system-assigned or user-assigned identities for the VM.

### Boot Diagnostics
- **boot_diagnostics** can be enabled with managed storage or a storage account URI.
- Diagnostic data may contain console output; treat access to storage accounts as sensitive.

### Diagnostic Settings
- **diagnostic_settings** forwards logs/metrics to Log Analytics, Storage, or Event Hub.
- Use explicit categories (`log_categories`, `log_category_groups`, `metric_categories`) to control log volume and exposure.

## Example: Security-Focused Configuration

```hcl
module "linux_virtual_machine" {
  source = "./modules/azurerm_linux_virtual_machine"

  name                = "linuxvm-secure"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2s"

  network = {
    network_interface_ids = [azurerm_network_interface.private.id]
  }

  admin = {
    username                        = "azureuser"
    disable_password_authentication = true
    ssh_keys = [
      {
        username   = "azureuser"
        public_key = file("~/.ssh/id_rsa.pub")
      }
    ]
  }

  image = {
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  security_profile = {
    secure_boot_enabled        = true
    vtpm_enabled               = true
    encryption_at_host_enabled = true
  }

  tags = {
    Environment = "Production"
  }
}
```

## Security Hardening Checklist

- [ ] Disable password authentication and use SSH keys only.
- [ ] Avoid public IPs; use private subnets and NSGs (out of scope).
- [ ] Enable secure boot and vTPM when supported by the image/region.
- [ ] Use managed identities instead of credentials where possible.
- [ ] Configure diagnostic settings with explicit categories.
- [ ] Treat runtime.custom_data/runtime.user_data as sensitive; avoid secrets in cleartext.
- [ ] Review boot diagnostics storage access and retention.

## Common Mistakes to Avoid

1. **Enabling password authentication without rotation controls**
2. **Exposing a VM with a public IP and permissive NSG rules**
3. **Placing secrets in cloud-init runtime.custom_data**
4. **Sending diagnostics to unsecured destinations**

## Additional Resources

- Azure VM security documentation
- Azure Monitor diagnostic settings guidance

---

**Last Updated**: 2026-01-30
