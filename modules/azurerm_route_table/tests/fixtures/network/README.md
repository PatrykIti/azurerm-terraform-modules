# Network Route Table Example

This example demonstrates complex network routing scenarios with hub-spoke topology and VNet peering.

## Features

- Hub-spoke network topology with three VNets
- Multiple route tables for different network tiers
- VNet peering configuration with transit routing
- Network Virtual Appliance (NVA) in hub for traffic inspection
- BGP route propagation enabled on hub, disabled on spokes
- Routes for spoke-to-spoke communication via hub
- Gateway routes for hybrid connectivity
- Comprehensive network segmentation

## Network Architecture

```
                    Internet
                        |
                   [Hub VNet]
                  10.0.0.0/16
                        |
        +---------------+---------------+
        |                               |
        |                               |
   [Spoke1 VNet]                   [Spoke2 VNet]
   10.1.0.0/16                     10.2.0.0/16
```

## Route Tables

### Hub Route Table
- Routes spoke traffic to NVA for inspection
- BGP propagation enabled for dynamic routing

### Spoke Route Tables
- Default route (0.0.0.0/0) to hub NVA
- Spoke-to-spoke routes via hub NVA
- On-premises routes via Virtual Network Gateway
- BGP propagation disabled for explicit routing control

## Key Configuration

- **Hub NVA**: Traffic inspection point at 10.0.3.4
- **Forced Tunneling**: All spoke traffic routed through hub
- **Transit Routing**: Hub acts as transit for spoke-to-spoke
- **Gateway Integration**: Ready for VPN/ExpressRoute connectivity

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