# Private Endpoint Module Documentation

## Overview

The Private Endpoint module provisions a single `azurerm_private_endpoint` and optional DNS zone group attachment. It follows the repo's atomic-module approach and keeps cross-resource glue (DNS zones, VNet links, RBAC, budgets) outside the module.

## Managed Resources

- `azurerm_private_endpoint`
  - `private_service_connection` (required; provider allows a single connection block)
  - `ip_configuration` (optional, multiple)
  - `private_dns_zone_group` (optional, max 1)

## Usage Notes

- `private_service_connections` must contain exactly one entry, and you must set **exactly one** of `private_connection_resource_id` or `private_connection_resource_alias`.
- `request_message` is required when `is_manual_connection` is `true`.
- `private_dns_zone_groups` accepts at most one group because the provider schema allows only a single `private_dns_zone_group` block.
- Subnet private endpoint network policies must be disabled (`private_endpoint_network_policies = "Disabled"`).
- Diagnostic settings are not managed by this module. Manage them separately if needed.

## Out of Scope

- Private DNS Zone creation and VNet links (`TASK-030`).
- Private DNS record sets (A/AAAA/CNAME/SRV/TXT/PTR/MX).
- RBAC / role assignments, policies, or budgets.
- Private Link Service resources.
- Virtual network or subnet creation outside of examples/fixtures.
