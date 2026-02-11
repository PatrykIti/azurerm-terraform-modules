# Private DNS Zone Virtual Network Link Module Documentation

## Overview

The `azurerm_private_dns_zone_virtual_network_link` module manages a single Virtual Network Link
for an existing Private DNS Zone. It requires a Private DNS Zone name and a Virtual Network ID.

## Managed Resources

- `azurerm_private_dns_zone_virtual_network_link`

## Usage Notes

- `registration_enabled` defaults to `false`. Enable it only for trusted networks that should
  auto-register VM records in the zone.
- `resolution_policy` is optional and supports `Default` or `NxDomainRedirect`.
- The module does not create the Private DNS Zone or the Virtual Network.

## Out of Scope

- Private DNS Zone creation (use `modules/azurerm_private_dns_zone`)
- Private DNS record sets (A/AAAA/CNAME/SRV/TXT/PTR/MX)
- Private endpoints, RBAC, policies, and budgets

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding documentation.
