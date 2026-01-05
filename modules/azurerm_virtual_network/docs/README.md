# Azure Virtual Network Module Documentation

Additional documentation for the Azure Virtual Network Terraform module.

## Overview

This module manages a single Azure Virtual Network resource. It does not create
subnets, peerings, diagnostic settings, private endpoints, or flow logs. Those
resources should be created alongside the module in your configuration.

## Managed Resources

- azurerm_virtual_network

## Usage Notes

- DDoS protection requires an existing DDoS plan. The module only attaches it.
- Encryption enforcement is optional and must be set explicitly.
- DNS servers should be limited to trusted resolvers.
- This module uses a flat input model because the resource is small.

## Inputs (Grouped)

- Core: name, resource_group_name, location, address_space
- Optional network: dns_servers, flow_timeout_in_minutes, bgp_community, edge_zone
- Security: ddos_protection_plan, encryption
- Tags: tags

## Outputs (Highlights)

- id, name, address_space, dns_servers
- network_configuration (summary of core settings)

## Import Existing VNet

See [docs/IMPORT.md](./IMPORT.md) for a step-by-step import guide.

## Troubleshooting

- Address space conflicts: verify no overlaps with existing VNets or peerings.
- DDoS plan association errors: confirm the plan exists in the same region.
- Unexpected plan changes: ensure inputs match the existing VNet properties.

## Related Docs

- [Module README](../README.md)
- [SECURITY.md](../SECURITY.md)
- [VERSIONING.md](../VERSIONING.md)
- [CONTRIBUTING.md](../CONTRIBUTING.md)
