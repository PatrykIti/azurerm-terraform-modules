# Private DNS Zone Module Documentation

## Overview

The `azurerm_private_dns_zone` module manages a single Azure Private DNS Zone. It is intentionally
atomic: it creates only the zone resource. Linking the zone to virtual networks is handled by the
separate `azurerm_private_dns_zone_virtual_network_link` module.

## Managed Resources

- `azurerm_private_dns_zone`

## Usage Notes

- Private DNS zone names must be valid DNS zone names without a trailing dot.
- `soa_record` is optional. When provided, `email` is required and time values are expressed in seconds.
- Virtual network links, record sets, RBAC, and budgets are out of scope for this module.

## Out of Scope

- Private DNS record sets (A/AAAA/CNAME/SRV/TXT/PTR/MX)
- Virtual network links (use `modules/azurerm_private_dns_zone_virtual_network_link`)
- Private endpoints, networking glue, RBAC, policies, and budgets

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding documentation.
