# Subnet Delegation Example

This example demonstrates subnet delegation to various Azure services, showing how to configure subnets that are dedicated to specific Azure service types and their required network policies.

## What this example creates

- Resource Group
- Virtual Network with multiple delegated subnets
- **5 subnets demonstrating different delegation scenarios**:
  1. **Container Instances Subnet** - Delegated to Azure Container Instances
  2. **PostgreSQL Subnet** - Delegated to Azure Database for PostgreSQL Flexible Server
  3. **App Service Subnet** - Delegated to Azure App Service (Web Apps)
  4. **Batch Subnet** - Delegated to Azure Batch
  5. **Regular Subnet** - No delegation (for comparison)
- Container Group deployed in the delegated subnet (demonstration)

## Use Case

This example is perfect for:
- Understanding subnet delegation concepts and requirements
- Planning network architecture for Azure PaaS services
- Learning about different service delegation requirements
- Implementing dedicated subnets for specific Azure services
- Comparing delegated vs. non-delegated subnet configurations

## Subnet Delegation Overview

Subnet delegation allows you to designate a specific subnet for a particular Azure service. When you delegate a subnet:
- The Azure service can inject service-specific resources into the subnet
- The service gets enhanced integration with your virtual network
- Network policies may be automatically adjusted for the service requirements
- The service has more control over the network configuration

## Features Demonstrated

### Container Instances Delegation
- **Service**: `Microsoft.ContainerInstance/containerGroups`
- **Actions**: Network join and network policy preparation
- **Network Policies**: Standard (enabled)
- **Service Endpoints**: Storage, Key Vault
- **Use Case**: Private container deployments with VNet integration

### PostgreSQL Flexible Server Delegation
- **Service**: `Microsoft.DBforPostgreSQL/flexibleServers`
- **Actions**: Network join
- **Network Policies**: Disabled (required for database services)
- **Service Endpoints**: None (not needed)
- **Use Case**: Private database deployments

### App Service Delegation
- **Service**: `Microsoft.Web/serverFarms`
- **Actions**: Network action permissions
- **Network Policies**: Standard (enabled)
- **Service Endpoints**: Storage, Key Vault, SQL
- **Use Case**: VNet-integrated web applications

### Batch Delegation
- **Service**: `Microsoft.Batch/batchAccounts`
- **Actions**: Network action permissions
- **Network Policies**: Standard (enabled)
- **Service Endpoints**: Storage
- **Use Case**: Batch processing workloads with VNet integration

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

### Network Layout
```
Virtual Network: 10.0.0.0/16
├── Container Instances Subnet: 10.0.1.0/24
├── PostgreSQL Subnet: 10.0.2.0/24
├── App Service Subnet: 10.0.3.0/24
├── Batch Subnet: 10.0.4.0/24
└── Regular Subnet: 10.0.5.0/24
```

### Delegation Configuration Patterns

Each delegation requires specific configuration:

```hcl
# Pattern for delegation configuration
delegations = {
  delegation_name = {
    name = "human_readable_name"
    service_delegation = {
      name    = "Microsoft.ServiceProvider/serviceType"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        # Additional service-specific actions
      ]
    }
  }
}
```

## Important Considerations

### Network Policy Requirements
- **Container Instances**: Standard network policies work fine
- **PostgreSQL/Database Services**: Require network policies to be **disabled**
- **App Service**: Standard network policies work fine
- **Batch**: Standard network policies work fine

### Service Endpoint Compatibility
- Most delegated subnets can still use service endpoints
- Database delegations typically don't need service endpoints
- App Service delegations benefit from Storage, Key Vault, and SQL endpoints

### Delegation Restrictions
- **One service per subnet**: Each subnet can only be delegated to one service type
- **Exclusive use**: Delegated subnets should only host the delegated service
- **Action requirements**: Each service requires specific network actions

## Common Delegation Services

| Service | Delegation Name | Network Policies | Common Use Case |
|---------|----------------|------------------|-----------------|
| Container Instances | Microsoft.ContainerInstance/containerGroups | Enabled | Private container deployments |
| PostgreSQL Flexible | Microsoft.DBforPostgreSQL/flexibleServers | **Disabled** | Private database access |
| MySQL Flexible | Microsoft.DBforMySQL/flexibleServers | **Disabled** | Private database access |
| App Service | Microsoft.Web/serverFarms | Enabled | VNet-integrated web apps |
| Azure Batch | Microsoft.Batch/batchAccounts | Enabled | Batch processing |
| API Management | Microsoft.ApiManagement/service | Enabled | Private API gateways |
| Azure Databricks | Microsoft.Databricks/workspaces | Enabled | Analytics workloads |

## Testing the Deployment

After deployment, verify the delegation:

1. **Check Container Instance**:
   ```bash
   # The container should have a private IP from the delegated subnet
   az container show --resource-group rg-subnet-delegation-example --name aci-delegation-example
   ```

2. **Verify Delegation Configuration**:
   ```bash
   # Check subnet delegation details
   az network vnet subnet show --resource-group rg-subnet-delegation-example --vnet-name vnet-subnet-delegation-example --name subnet-container-instances
   ```

## Best Practices

1. **Plan subnet sizes carefully** - Delegated subnets cannot be shared
2. **Consider future scaling** - Size subnets appropriately for service growth
3. **Use meaningful names** - Clearly identify the delegated service in subnet names
4. **Document requirements** - Track which services need which network policy settings
5. **Monitor utilization** - Keep track of IP address usage in delegated subnets

## Example terraform.tfvars

```hcl
location = "West Europe"
```

## Extension Ideas

This example can be extended to include:
- Azure SQL Managed Instance delegation
- Azure Kubernetes Service node pool delegation
- Azure Container Apps delegation
- Multiple container groups in the same delegated subnet
- Network security group rules specific to each delegated service