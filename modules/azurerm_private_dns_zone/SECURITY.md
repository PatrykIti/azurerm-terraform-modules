# azurerm_private_dns_zone Module Security

## Overview

Azure Private DNS Zones are private by design and only resolve within linked virtual networks.
This module creates the zone only; network exposure is controlled by separate Virtual Network
Links and private endpoints.

## Security Considerations

- **Access scope**: DNS resolution is limited to networks linked to the zone.
- **Isolation**: Use dedicated resource groups and tags for ownership, compliance, and auditing.
- **Auto-registration**: VM auto-registration is controlled on the link resource, not on the zone.

## Secure Example

```hcl
module "private_dns_zone" {
  source = "./modules/azurerm_private_dns_zone"

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment        = "Production"
    DataClassification = "Confidential"
  }
}
```

Pair the zone with `azurerm_private_dns_zone_virtual_network_link` in a separate module to
limit resolution only to trusted networks.

## Hardening Checklist

- [ ] Use a dedicated resource group for DNS assets.
- [ ] Link the zone only to required VNets.
- [ ] Enable auto-registration only for trusted workloads.
- [ ] Track DNS changes via Azure Activity Logs.
- [ ] Keep record set management in dedicated modules.

## Common Pitfalls

- **Broad linking**: Linking the zone to shared VNets expands resolution scope.
- **Auto-registration everywhere**: Enabling `registration_enabled` on multiple links can pollute the zone.
- **Mixed environments**: Reusing zones across environments complicates lifecycle and audit trails.
