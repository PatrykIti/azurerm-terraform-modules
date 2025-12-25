# azurerm_route_table Module Security

## Overview

This document describes the security considerations for the `azurerm_route_table` module.
Route tables control packet paths in Azure. Incorrect routes can expose workloads or
break isolation, so this module focuses on explicit route configuration and validation.

## Security Features

- **Explicit route control** for predictable traffic paths.
- **Forced tunneling support** via default routes to a virtual appliance.
- **Blackhole routes** using `next_hop_type = "None"` to block destinations.
- **BGP propagation control** to prevent dynamic routes from overriding explicit paths.
- **Input validation** for CIDR, next hop types, and naming.

## Secure Configuration Example

```hcl
module "route_table" {
  source = "./modules/azurerm_route_table"

  name                = "rt-secure-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Disable BGP propagation to keep routing deterministic
  bgp_route_propagation_enabled = false

  # Force all outbound traffic through a firewall/NVA
  routes = [
    {
      name                   = "force-to-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    },
    {
      name           = "block-bad-range"
      address_prefix = "203.0.113.0/24"
      next_hop_type  = "None"
    }
  ]

  tags = {
    Environment        = "Production"
    DataClassification = "Confidential"
  }
}
```

## Security Hardening Checklist

- [ ] Use explicit routes for sensitive subnets.
- [ ] Disable BGP propagation if dynamic routes could bypass security controls.
- [ ] Force egress through a firewall/NVA where required.
- [ ] Add blackhole routes for known-bad destinations.
- [ ] Review routes regularly and remove obsolete entries.

## Common Security Mistakes to Avoid

1. **Unexpected Internet egress**
   ```hcl
   # ❌ AVOID
   routes = [
     {
       name           = "to-internet"
       address_prefix = "0.0.0.0/0"
       next_hop_type  = "Internet"
     }
   ]
   ```

2. **Virtual appliance without IP**
   ```hcl
   # ❌ AVOID
   next_hop_type = "VirtualAppliance"
   # missing next_hop_in_ip_address
   ```

3. **Overlapping or conflicting routes**
   - Ensure routes do not unintentionally override each other.

## Incident Response

1. **Immediate Actions**
   - Review current routes for unexpected paths.
   - Disable BGP propagation if dynamic routes appear.

2. **Investigation**
   - Compare current route tables to approved baselines.
   - Validate next hop IPs and subnet associations.

3. **Remediation**
   - Restore approved routes.
   - Add blackhole routes for malicious destinations.

## Compliance Mapping

### SOC 2 Controls
| Control | Implementation |
|---------|---------------|
| CC6.1 | Network routing control via explicit routes |
| CC7.2 | Change control through Terraform state |

### ISO 27001 Controls
| Control | Implementation |
|---------|---------------|
| A.9.1.2 | Network access controls via routing rules |
| A.12.1.2 | Change management via IaC |

## Additional Resources

- [Azure Route Tables Overview](https://learn.microsoft.com/azure/virtual-network/virtual-networks-udr-overview)
- [Route Table Best Practices](https://learn.microsoft.com/azure/virtual-network/virtual-network-route-table)

---

**Module Version**: 1.0.3  
**Last Updated**: 2025-12-25  
**Security Contact**: security@yourorganization.com
