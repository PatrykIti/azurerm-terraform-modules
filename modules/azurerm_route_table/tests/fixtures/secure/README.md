# Secure Route Table Example

This example demonstrates a security-focused Route Table configuration suitable for highly sensitive data and regulated environments.

## Features

- Security-focused routing configuration
- Multiple subnet tiers (DMZ, Application, Database, Security)
- All traffic forced through security appliance (firewall/IDS)
- BGP route propagation disabled for maximum control
- Explicit deny routes for unauthorized traffic
- RFC1918 private address blocking
- Database subnet isolation
- Comprehensive security tagging

## Key Configuration

This example implements defense-in-depth routing principles:
- **Forced Tunneling**: All Internet traffic routed through security appliance
- **Network Segmentation**: Separate subnets for different security zones
- **Explicit Deny**: Specific routes to drop unauthorized traffic
- **Zero Trust**: No implicit trust, all traffic inspected
- **Compliance Ready**: Tagged for PCI-DSS compliance tracking

## Security Routes

1. **Internet via Firewall**: Forces all outbound traffic through security appliance
2. **DMZ Protection**: DMZ traffic routed through security inspection
3. **Database Isolation**: Direct database access blocked with 'None' route
4. **VPN Security**: VPN traffic inspected by security appliance
5. **RFC1918 Blocking**: Private address ranges blocked by default
6. **Local VNet**: Only local VNet traffic allowed directly

## Network Architecture

```
Internet <--> Security Appliance (10.0.100.4) <--> Application/Database Subnets
                        |
                        v
                  Inspection/Filtering
```

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
