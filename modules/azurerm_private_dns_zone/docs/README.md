# Private DNS Zone Module Documentation

## Overview

The `azurerm_private_dns_zone` module manages a single Azure Private DNS Zone. It is intentionally
atomic: it creates only the zone resource. Linking the zone to virtual networks is handled by the
separate `azurerm_private_dns_zone_virtual_network_link` module.

## Managed Resources

- `azurerm_private_dns_zone`

## Provider Capability Mapping

| Capability | Status | Notes |
|------------|--------|-------|
| Core Private DNS zone (`name`, `resource_group_name`, `tags`) | Implemented | Managed by `azurerm_private_dns_zone.private_dns_zone`. |
| SOA record configuration (`soa_record`) | Implemented | Optional input mapped to the resource `soa_record` block. |
| Custom timeouts (`timeouts`) | Implemented | Optional input mapped to Terraform resource timeouts. |
| Virtual network links | N/A in this module | Use `modules/azurerm_private_dns_zone_virtual_network_link`. |
| DNS record sets (A/AAAA/CNAME/SRV/TXT/PTR/MX) | Intentional omission | Managed by dedicated record-set modules. |
| `location` and `network_rules` arguments | N/A for this resource | Not supported by `azurerm_private_dns_zone`. |
| RBAC, private endpoints, budgets, broader network glue | Intentional omission | Kept out of scope for atomic module design. |

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
