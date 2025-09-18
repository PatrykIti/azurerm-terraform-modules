# Complete Route Table Example

This example demonstrates a comprehensive deployment of Route Tables with all available features and advanced routing scenarios.

## Features

- **Multiple Route Tables**: Demonstrates different routing strategies
- **Hub-Spoke Architecture**: Routes configured for hub-spoke topology with firewall
- **All Next Hop Types**: Shows usage of all available next hop types
- **BGP Control**: Examples of both enabled and disabled BGP propagation
- **Multiple Subnet Associations**: Associates route tables with multiple subnets
- **Security Patterns**: Includes force tunneling and traffic blackholing

## Key Configuration

### Hub Route Table
- Disables BGP route propagation for full control
- Routes all traffic through central firewall (NVA)
- Includes routes for:
  - Default route to firewall
  - On-premises connectivity via VPN Gateway
  - Spoke networks via firewall
  - Local VNet traffic
  - Blackhole route for blocking specific IPs

### DMZ Route Table
- Keeps BGP propagation enabled
- Direct internet connectivity for DMZ resources

## Network Architecture

```
Internet
    |
    v
[Azure Firewall] (10.0.0.4)
    |
    +--[Hub VNet]--+
    |              |
[App Subnet]   [Data Subnet]
(10.0.1.0/24)  (10.0.2.0/24)
    |              |
    +-- Route Table--+
```

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Security Considerations

1. The firewall subnet (AzureFirewallSubnet) doesn't have a route table associated
2. All traffic from app and data subnets is forced through the firewall
3. BGP propagation is disabled to prevent route injection
4. Blackhole routes can be used to block specific destinations

## Cleanup

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->