# azurerm_private_endpoint Module Security

## Overview

This module provisions an Azure Private Endpoint with optional private DNS zone group attachment. It supports secure-by-default private connectivity but requires the surrounding network and DNS configuration to be correct.

## Security Posture

- **Network isolation**: Private Endpoints provide private IPs inside your VNet. Ensure subnets used for Private Endpoints have `private_endpoint_network_policies` disabled.
- **Private DNS**: Use Private DNS zones and VNet links so name resolution stays on private IPs. Misconfigured DNS can cause fallback to public endpoints.
- **Manual approval**: When you do not own the target resource or lack permissions, set `is_manual_connection = true` and provide `request_message`.
- **Public access**: Disable public network access on the target resource whenever the service supports it.

## Secure Example

```hcl
module "private_endpoint" {
  source = "./modules/azurerm_private_endpoint"

  name                = "pe-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connections = [
    {
      name                           = "pe-secure-psc"
      is_manual_connection           = false
      private_connection_resource_id = azurerm_storage_account.example.id
      subresource_names              = ["blob"]
    }
  ]

  private_dns_zone_groups = [
    {
      name                 = "pe-secure-dns"
      private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
    }
  ]

  tags = {
    Environment = "Production"
  }
}
```

## Security Checklist

- [ ] Subnet has `private_endpoint_network_policies = "Disabled"`.
- [ ] Private DNS zone and VNet link configured for the service subresource.
- [ ] Public network access disabled on the target resource (when supported).
- [ ] Manual connection configured when cross-tenant or lacking RBAC.
- [ ] Tags applied for ownership and data classification.

## Common Mistakes

- **No Private DNS zone link**: traffic resolves to public endpoints.
- **Wrong subresource name**: connection fails or points to the wrong service endpoint.
- **Manual approval without request_message**: provisioning fails validation.
