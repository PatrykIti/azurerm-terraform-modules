# Complete Route Table Example

This example demonstrates a comprehensive deployment of Route Table with all available features and configurations.

## Features

- Full Route Table configuration with all route types
- Multiple custom routes demonstrating different next hop types:
  - Internet route for outbound traffic
  - Virtual Appliance route for network security
  - Virtual Network Gateway route for hybrid connectivity
  - VNet Local route for internal traffic
  - None route for dropping specific traffic
- BGP route propagation disabled for full routing control
- Virtual network and subnet creation
- Network virtual appliance (NVA) setup
- Route table association with multiple subnets
- Comprehensive tagging strategy

## Key Configuration

This comprehensive example showcases all available features of the route table module:
- All five types of next hop configurations
- Network virtual appliance with static IP
- Multiple subnet associations
- Complete routing scenario for enterprise environments

## Route Types Demonstrated

1. **Internet Route**: Default route (0.0.0.0/0) to Internet
2. **Virtual Appliance Route**: Traffic to 10.1.0.0/16 via NVA at 10.0.1.4
3. **Virtual Network Gateway Route**: Traffic to 10.2.0.0/16 via VPN/ExpressRoute
4. **VNet Local Route**: Local VNet traffic stays within 10.0.0.0/16
5. **None Route**: Drops traffic to 192.168.0.0/16

## Usage

```bash
terraform init
terraform plan -var="random_suffix=test123"
terraform apply -var="random_suffix=test123"
```

## Cleanup

```bash
terraform destroy -var="random_suffix=test123"
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
