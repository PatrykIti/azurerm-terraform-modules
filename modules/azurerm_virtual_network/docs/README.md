# Azure Virtual Network Module Documentation

This directory contains additional documentation for the Azure Virtual Network Terraform module.

## Documentation Structure

### Main Documentation
- [`../README.md`](../README.md) - Main module documentation with usage examples
- [`../CHANGELOG.md`](../CHANGELOG.md) - Version history and change tracking
- [`../CONTRIBUTING.md`](../CONTRIBUTING.md) - Contribution guidelines
- [`../VERSIONING.md`](../VERSIONING.md) - Versioning strategy and guidelines

### Examples
- [`../examples/basic/`](../examples/basic/) - Basic virtual network setup
- [`../examples/complete/`](../examples/complete/) - Full-featured enterprise deployment with peering
- [`../examples/secure/`](../examples/secure/) - Maximum security configuration with DDoS protection
- [`../examples/private-endpoint/`](../examples/private-endpoint/) - Private endpoint configuration

### Configuration Files
- [`../.terraform-docs.yml`](../.terraform-docs.yml) - Terraform-docs configuration
- [`../generate-docs.sh`](../generate-docs.sh) - Documentation generation script

## Quick Start

### 1. Basic Usage
```hcl
module "vnet" {
  source = "path/to/azurerm_virtual_network"
  
  name                = "vnet-example"
  resource_group_name = "my-resource-group"
  location            = "westeurope"
  address_space       = ["10.0.0.0/16"]
}
```

### 2. Generate Documentation
```bash
cd ..
./generate-docs.sh
```

### 3. Run Examples
```bash
cd ../examples/basic
terraform init
terraform plan
```

## Module Features

### Core Capabilities
- ✅ Virtual network creation with multiple address spaces
- ✅ Subnet management with delegation support
- ✅ Network security group associations
- ✅ Route table associations
- ✅ Service endpoints configuration
- ✅ Private endpoint network policies
- ✅ VNet peering support
- ✅ DDoS protection plan integration

### Enterprise Features
- ✅ Hub-spoke network topologies
- ✅ DNS server configuration
- ✅ Flow logs and network watcher integration
- ✅ Network security baseline compliance
- ✅ Custom DNS zones support
- ✅ BGP community support

## Architecture Patterns

### Basic Network
- Simple VNet for development/testing
- Single address space
- Basic subnet configuration
- Cost-effective for non-production workloads

### Hub-Spoke Topology
- Centralized connectivity and security
- Shared services in hub VNet
- Workload isolation in spoke VNets
- Optimized routing and security policies

### Secure Network
- DDoS protection enabled
- Network security groups on all subnets
- Flow logs for audit and compliance
- Private endpoint optimized
- Forced tunneling support

## Security Best Practices

1. **Network Segmentation**
   - Use multiple subnets for workload isolation
   - Implement network security groups at subnet level
   - Apply principle of least privilege for NSG rules

2. **Access Control**
   - Disable public IP allocation where possible
   - Use private endpoints for PaaS services
   - Implement Azure Firewall for centralized security

3. **Monitoring**
   - Enable flow logs for all subnets
   - Configure Network Watcher
   - Set up alerts for security events

4. **DDoS Protection**
   - Enable DDoS Protection Standard for production
   - Configure mitigation policies
   - Monitor DDoS metrics

## Subnet Planning

### Address Space Design
```
10.0.0.0/16 - VNet Address Space
├── 10.0.0.0/24   - GatewaySubnet (Reserved)
├── 10.0.1.0/24   - AzureFirewallSubnet (Reserved)
├── 10.0.2.0/24   - AzureBastionSubnet (Reserved)
├── 10.0.10.0/24  - Web Tier
├── 10.0.20.0/24  - App Tier
├── 10.0.30.0/24  - Data Tier
└── 10.0.100.0/24 - Management
```

### Special Subnets
- **GatewaySubnet**: Required for VPN/ExpressRoute gateways
- **AzureFirewallSubnet**: Required for Azure Firewall (/26 minimum)
- **AzureBastionSubnet**: Required for Azure Bastion (/27 minimum)

## Troubleshooting

### Common Issues

1. **Address Space Conflicts**
   - Check for overlapping IP ranges
   - Verify peered VNets don't have conflicts
   - Use Azure IP Address Manager

2. **Subnet Delegation Failures**
   - Ensure service supports delegation
   - Check for conflicting delegations
   - Verify subnet size requirements

3. **Peering Connection Issues**
   - Verify both VNets exist in allowed regions
   - Check for address space overlap
   - Ensure proper permissions

### Debug Commands
```bash
# Check VNet configuration
az network vnet show --name <vnet-name> --resource-group <rg-name>

# List all subnets
az network vnet subnet list --vnet-name <vnet-name> --resource-group <rg-name>

# Check effective routes
az network nic show-effective-route-table --name <nic-name> --resource-group <rg-name>

# Verify NSG rules
az network nsg rule list --nsg-name <nsg-name> --resource-group <rg-name>
```

## Cost Optimization

1. **Right-size Address Spaces**
   - Plan for growth but avoid excessive allocation
   - Use smaller subnets where appropriate
   - Consider IPv6 for future-proofing

2. **Optimize Data Transfer**
   - Use VNet peering instead of VPN where possible
   - Implement Azure Private Link
   - Consider ExpressRoute for high-volume scenarios

3. **Security Services**
   - Share DDoS Protection Plan across VNets
   - Centralize Azure Firewall in hub VNet
   - Use NSGs instead of NVAs where sufficient

## Additional Resources

- [Azure Virtual Network Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/)
- [Azure Network Security Best Practices](https://docs.microsoft.com/en-us/azure/security/fundamentals/network-best-practices)
- [Hub-Spoke Network Topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure Network Limits](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#networking-limits)

## Support

For issues, questions, or contributions:
1. Check existing issues in the repository
2. Review the contributing guidelines
3. Open a new issue with detailed information
4. Follow the pull request process for contributions
