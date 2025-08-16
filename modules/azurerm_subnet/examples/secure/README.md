# Secure Subnet Example

This example demonstrates a security-focused subnet configuration with enhanced security features including DDoS protection, restrictive network security groups, secure routing, and comprehensive monitoring.

## What this example creates

- Resource Group
- Virtual Network with DDoS Protection Plan
- Secure subnet with restrictive network policies
- Highly restrictive Network Security Group with minimal access rules
- Route Table with security-focused routing through virtual appliance
- Log Analytics Workspace for security monitoring
- Storage Account with enhanced security settings for log storage
- Network Watcher for flow log monitoring
- Flow logs with traffic analytics for security monitoring

## Use Case

This example is perfect for:
- Production environments requiring high security
- Compliance-focused deployments (SOC 2, ISO 27001, etc.)
- Zero-trust network architectures
- Environments handling sensitive data
- Scenarios requiring comprehensive network monitoring and logging

## Security Features Demonstrated

### Network Security
- DDoS Protection Plan for enhanced DDoS mitigation
- Restrictive NSG rules allowing only necessary traffic
- Network policies enabled for private endpoints and private link services
- Custom routing through security appliances

### Access Control
- HTTPS-only access from trusted IP ranges
- Service endpoints for secure access to Azure services
- VNet-to-VNet communication restrictions
- Default deny rules for all other traffic

### Monitoring & Logging
- Extended log retention (90 days) for compliance
- Network Watcher flow logs with traffic analytics
- Storage account with geo-redundant replication for log durability
- Enhanced storage security (HTTPS-only, TLS 1.2, no public access)

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Clean up when done
terraform destroy
```

## Configuration Details

### Network Configuration
- Virtual Network: `10.0.0.0/16` with DDoS protection
- Subnet: `10.0.1.0/24` with enhanced security
- Custom routing through security appliance at `10.0.10.4`

### Security Configuration
- NSG allows only HTTPS (443) from trusted IP ranges
- All other inbound traffic is denied by default
- Outbound traffic restricted to Azure services and VNet
- Flow logs enabled with 10-minute intervals

### Service Endpoints
The secure subnet includes service endpoints for:
- Microsoft.Storage
- Microsoft.KeyVault
- Microsoft.AzureActiveDirectory

## Important Security Considerations

⚠️ **Before deploying to production, update the following:**

1. **Trusted IP Ranges**: Replace placeholder IP ranges in NSG rules:
   ```hcl
   source_address_prefixes = ["203.0.113.0/24", "198.51.100.0/24"]
   ```

2. **Security Appliance IP**: Update the virtual appliance IP address:
   ```hcl
   next_hop_in_ip_address = "10.0.10.4"
   ```

3. **Storage Account Name**: Ensure globally unique storage account naming

4. **Log Retention**: Adjust retention periods based on compliance requirements

## Example terraform.tfvars

```hcl
location = "West Europe"
```

## Compliance Notes

This configuration supports various compliance frameworks:
- **SOC 2**: Network monitoring, access controls, DDoS protection
- **ISO 27001**: Security controls, monitoring, incident response capabilities
- **PCI DSS**: Network segmentation, access controls, monitoring
- **GDPR**: Data protection through network security and monitoring

## Monitoring and Alerting

Consider setting up additional monitoring:
- Azure Security Center recommendations
- Network security group flow log analysis
- DDoS protection metrics and alerts
- Traffic analytics insights for anomaly detection