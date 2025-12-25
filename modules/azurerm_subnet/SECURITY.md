# azurerm_subnet Module Security

## Overview

This document describes security considerations for the azurerm_subnet module. The module configures subnet policies, service endpoints, delegations, and optional associations to other network resources.

## Secure Example

See the hardened baseline in `examples/secure`, which focuses on restrictive network access and least-privilege defaults.

## Security Features

### 1. Network Policies
- **Private Endpoint Policies**: Enabled by default; disable only for subnets hosting private endpoints.
- **Private Link Service Policies**: Enabled by default; disable only when required.

### 2. Service Endpoints
- Restrict service access to Microsoft-managed backbones.
- Optional **Service Endpoint Policies** to limit access to specific storage accounts.

### 3. Network Controls
- Optional associations to **NSGs** for traffic filtering.
- Optional associations to **Route Tables** for forced routing or segmentation.

### 4. Delegations
- Delegate subnets to specific Azure services to enforce scoped permissions.
- Use dedicated subnets for delegated workloads to avoid mixed responsibilities.

## Security Hardening Checklist

- [ ] Use NSGs for inbound/outbound traffic controls.
- [ ] Keep private endpoint policies enabled unless private endpoints are required.
- [ ] Use service endpoints only for required services.
- [ ] Apply service endpoint policies for storage where possible.
- [ ] Separate delegated subnets by service type.
- [ ] Review route table associations for least-privilege routing.

## Common Security Mistakes to Avoid

1. **Disabling private endpoint policies on general-purpose subnets**
2. **Broad service endpoints without policies**
3. **Combining multiple delegated services in a single subnet**
4. **Missing NSG associations for production subnets**

## Additional Resources

- [Azure Subnet Security](https://learn.microsoft.com/azure/virtual-network/virtual-network-manage-subnet)
- [Service Endpoints](https://learn.microsoft.com/azure/virtual-network/virtual-network-service-endpoints-overview)
- [Private Endpoint Policies](https://learn.microsoft.com/azure/private-link/private-endpoint-overview)

---

**Module Version**: 1.0.3  
**Last Updated**: 2025-12-25  
**Security Contact**: security@yourorganization.com
