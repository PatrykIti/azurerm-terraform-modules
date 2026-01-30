# azurerm_private_dns_zone_virtual_network_link Module Security

## Overview

Virtual Network Links control which VNets can resolve a Private DNS Zone and whether those
VNets can auto-register VM records. This module manages a single link and does not create
the zone or VNet.

## Security Considerations

- **registration_enabled**: Defaults to `false`. Enable only for trusted networks that should
  auto-register VM records into the zone.
- **Resolution scope**: Each link extends DNS resolution to the target VNet.
- **Least privilege**: Use RBAC at the resource group level to control who can update links.

## Secure Example

```hcl
module "private_dns_zone_virtual_network_link" {
  source = "./modules/azurerm_private_dns_zone_virtual_network_link"

  name                  = "prod-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id

  registration_enabled = false

  tags = {
    Environment = "Production"
    Owner       = "Network"
  }
}
```

## Hardening Checklist

- [ ] Keep `registration_enabled` disabled unless required.
- [ ] Link only the VNets that must resolve the zone.
- [ ] Use tags to track ownership and environment.
- [ ] Review Activity Logs for link changes.

## Common Pitfalls

- **Unrestricted registration**: Enabling auto-registration in shared VNets can create unwanted records.
- **Over-linking**: Linking a zone to multiple VNets expands resolution surface area.
- **Missing governance**: Lack of tagging or ownership makes cleanup and audits difficult.
