# Complete Subnet Example

This example demonstrates a comprehensive subnet configuration with all available features including service endpoints, network security groups, route tables, and service endpoint policies.

## What this example creates

- Resource Group
- Virtual Network
- Subnet with multiple address prefixes
- Network Security Group with traffic rules
- Route Table with custom routes
- Storage Account for service endpoint demonstration
- Service Endpoint Policy for storage access control
- All necessary associations between resources

## Use Case

This example is perfect for:
- Production subnet deployments
- Complex network configurations requiring fine-grained control
- Scenarios requiring service endpoint policies
- Environments with specific routing requirements
- Security-conscious deployments with NSG rules

## Features Demonstrated

- Multiple address prefixes on a single subnet
- Service endpoints for multiple Azure services (Storage, KeyVault, SQL, EventHub, ServiceBus)
- Service endpoint policies for access control
- Network Security Group association with traffic rules
- Route Table association with custom routing
- Storage account integration with service endpoints

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
- Virtual Network: `10.0.0.0/16`
- Subnet Address Prefixes: `10.0.1.0/24`, `10.0.2.0/24`
- Custom route to virtual appliance: `10.0.10.4`

### Security Configuration
- NSG rules allowing HTTP (80) and HTTPS (443) traffic
- Service endpoint policy restricting storage access to specific accounts
- Network policies enabled for both private endpoints and private link services

### Service Endpoints
The subnet is configured with service endpoints for:
- Microsoft.Storage
- Microsoft.KeyVault
- Microsoft.Sql
- Microsoft.EventHub
- Microsoft.ServiceBus

## Example terraform.tfvars

```hcl
location = "West Europe"
```

## Important Notes

- The service endpoint policy includes placeholder subscription IDs that should be replaced with actual values in production
- The virtual appliance IP address (10.0.10.4) should be updated to match your actual network topology
- Storage account names must be globally unique - the example uses a generated name that may need adjustment