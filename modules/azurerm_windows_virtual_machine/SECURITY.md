# azurerm_windows_virtual_machine Module Security

## Overview

This document describes security considerations for the Windows Virtual Machine
module. The module is security-first but relies on the caller to supply secure
networking, identity, and monitoring dependencies.

## Key Security Considerations

### RDP Exposure
- Avoid public IPs in production. Prefer Azure Bastion or private access.
- If RDP is required, restrict inbound access with NSG rules to trusted IPs.

### Credentials
- `admin.password` must be strong (12+ chars, 3 of 4 complexity categories).
- Avoid hardcoding passwords. Use `random_password` or secrets from a secure
  pipeline, and rotate regularly.

### WinRM
- Use HTTPS (`protocol = "Https"`) with a Key Vault certificate where possible.
- Avoid HTTP WinRM in production workloads.

### Encryption
- Enable `encryption_at_host_enabled` when supported.
- Use `secure_boot_enabled` and `vtpm_enabled` for Trusted Launch VMs.
- If using Disk Encryption Sets, ensure `identity.type` includes UserAssigned.

### Boot Diagnostics
- Boot diagnostics data may contain sensitive information. Use managed storage
  or dedicated storage accounts with restricted access.

## Secure Example Guidance

The `examples/secure` configuration demonstrates:
- No public IP
- Private subnet NIC
- NSG with limited RDP ingress
- Trusted Launch options where supported

## Security Checklist

- [ ] No public IP on production VMs
- [ ] NSG restricts RDP to trusted CIDRs
- [ ] Strong admin password stored securely
- [ ] Trusted Launch (`secure_boot_enabled`, `vtpm_enabled`) where supported
- [ ] `encryption_at_host_enabled` enabled when available
- [ ] Diagnostics enabled and sent to a protected workspace

## Common Mistakes

- Leaving public IPs exposed with open RDP rules
- Reusing weak or shared admin passwords
- Using HTTP WinRM in production
- Skipping diagnostics in regulated environments

## Additional Resources

- Azure Windows VM security best practices
- Azure Bastion for secure RDP access
- Azure Disk Encryption and Disk Encryption Sets
