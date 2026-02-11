# Import

## Private Endpoint

```hcl
import {
  to = azurerm_private_endpoint.private_endpoint
  id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/privateEndpoints/example-pe"
}
```

## Notes

- The Private DNS zone group is managed through the `private_dns_zone_group` block on `azurerm_private_endpoint` in azurerm v4.57.0.
- After import, set `private_dns_zone_groups` to match the existing DNS zone group (if any).
