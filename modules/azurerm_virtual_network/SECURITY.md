# azurerm_virtual_network Module Security

## Overview

This document describes the security-related configuration available in the
azurerm_virtual_network module. The module manages only the VNet resource; all
network controls for subnets, NSGs, private endpoints, and diagnostics are
configured outside the module.

## Security Features

### DDoS Protection Plan Association

- The module can associate an existing DDoS plan with the VNet.
- The DDoS plan must already exist in the same region.

### Encryption Enforcement

- The module can enforce VNet encryption behavior via `encryption.enforcement`.
- Supported values: `AllowUnencrypted` or `DropUnencrypted`.

### DNS Server Configuration

- Custom DNS servers can be configured to enforce trusted name resolution.
- Use only internal or approved DNS resolvers.

## Security Configuration Example

```hcl
module "virtual_network" {
  source = "./modules/azurerm_virtual_network"

  name                = "vnet-secure"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]

  ddos_protection_plan = {
    id     = azurerm_network_ddos_protection_plan.main.id
    enable = true
  }

  encryption = {
    enforcement = "DropUnencrypted"
  }

  tags = {
    Environment = "Production"
  }
}
```

## Security Hardening Checklist

- Associate a DDoS protection plan where required.
- Enable encryption enforcement if mandated by policy.
- Use subnet-level NSGs and route tables (outside this module).
- Enable diagnostic settings for the VNet (outside this module).
- Use private endpoints and service endpoints as needed (outside this module).

## Common Security Mistakes to Avoid

1. Leaving DDoS protection unconfigured in production.
2. Using untrusted DNS servers.
3. Assuming the module creates NSGs, diagnostics, or private endpoints.

## Additional Resources

- https://learn.microsoft.com/azure/virtual-network/virtual-network-overview
- https://learn.microsoft.com/azure/ddos-protection/ddos-protection-overview
- https://learn.microsoft.com/azure/virtual-network/virtual-network-encryption
