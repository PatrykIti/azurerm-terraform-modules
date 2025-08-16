# Private Endpoint Subnet Example

This example demonstrates subnet configuration optimized for private endpoint scenarios, showing how to properly configure subnets for private endpoint connectivity to Azure services.

## What this example creates

- Resource Group
- Virtual Network with Azure-provided DNS
- Two subnets:
  - **Private Endpoints Subnet**: Optimized for hosting private endpoints
  - **Workloads Subnet**: For application workloads that access private endpoints
- Storage Account (with public access disabled)
- Key Vault (with public access disabled)
- Private DNS Zones for service resolution
- Private Endpoints for both Storage (blob) and Key Vault
- DNS zone links for proper name resolution

## Use Case

This example is perfect for:
- Secure connectivity to Azure PaaS services
- Zero-trust network architectures
- Compliance requirements that mandate private connectivity
- Hybrid scenarios requiring private access from on-premises
- Applications that need secure access to Azure services without internet traversal

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Virtual Network                          │
│                    10.0.0.0/16                             │
│                                                             │
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │  Private Endpoints  │    │       Workloads            │ │
│  │     Subnet          │    │       Subnet               │ │
│  │   10.0.1.0/24       │    │     10.0.2.0/24            │ │
│  │                     │    │                            │ │
│  │ ┌─────────────────┐ │    │ ┌───────────────────────────┐ │
│  │ │ Storage PE      │ │    │ │                          │ │
│  │ │ 10.0.1.4        │ │    │ │    Application VMs       │ │
│  │ └─────────────────┘ │    │ │                          │ │
│  │ ┌─────────────────┐ │    │ │                          │ │
│  │ │ Key Vault PE    │ │    │ │                          │ │
│  │ │ 10.0.1.5        │ │    │ │                          │ │
│  │ └─────────────────┘ │    │ └───────────────────────────┘ │
│  └─────────────────────┘    └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                               │
                    ┌─────────────────────┐
                    │   Private DNS       │
                    │      Zones          │
                    │                     │
                    │ blob.core.windows   │
                    │ vaultcore.azure     │
                    └─────────────────────┘
```

## Features Demonstrated

### Subnet Configuration
- **Private Endpoint Subnet**: Network policies disabled for private endpoints (required)
- **Workload Subnet**: Standard configuration for application workloads
- Proper subnet segmentation for different purposes

### Private Connectivity
- Storage Account with blob private endpoint
- Key Vault with vault private endpoint
- Private DNS zones for proper name resolution
- Public access disabled on Azure services

### DNS Resolution
- Private DNS zones for Azure services
- Virtual network links for DNS resolution
- Automatic DNS registration for private endpoints

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
- Private Endpoints Subnet: `10.0.1.0/24`
- Workloads Subnet: `10.0.2.0/24`

### Private Endpoints
- **Storage Blob**: `privatelink.blob.core.windows.net`
- **Key Vault**: `privatelink.vaultcore.azure.net`

### Important Subnet Settings
- Private endpoint network policies: **Disabled** (required for private endpoints)
- Private link service network policies: **Enabled** (not needed for this scenario)
- No service endpoints configured (private endpoints replace them)

## Testing Private Connectivity

After deployment, you can test private connectivity:

1. **Deploy a VM in the workloads subnet**
2. **Test Storage connectivity**:
   ```bash
   nslookup stsubnetprivateendpt.blob.core.windows.net
   # Should resolve to private IP (10.0.1.x)
   ```

3. **Test Key Vault connectivity**:
   ```bash
   nslookup kv-subnet-pe-example.vault.azure.net
   # Should resolve to private IP (10.0.1.x)
   ```

## Security Benefits

- **No Internet Traffic**: All communication to Azure services stays within Azure backbone
- **Network Isolation**: Services are not accessible from the internet
- **Firewall Control**: Traffic can be inspected and controlled by network virtual appliances
- **Audit Trail**: All connections are logged and can be monitored

## Best Practices Demonstrated

1. **Subnet Segmentation**: Separate subnets for private endpoints and workloads
2. **DNS Integration**: Proper private DNS configuration for seamless connectivity
3. **Security**: Public access disabled on Azure services
4. **Network Policies**: Correct configuration for private endpoint scenarios

## Example terraform.tfvars

```hcl
location = "West Europe"
```

## Common Patterns

This example can be extended for:
- SQL Database private endpoints
- Cosmos DB private endpoints  
- App Service private endpoints
- Container Registry private endpoints
- Multiple workload subnets with different access patterns